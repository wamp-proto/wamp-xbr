import uuid
import binascii

import cbor2
import nacl.secret
import nacl.utils
import nacl.exceptions

import txaio
from autobahn.twisted.util import sleep

import eth_keys
from eth_account import Account


class SimpleBuyer(object):

    log = txaio.make_logger()

    def __init__(self, private_key):
        self._pkey = eth_keys.keys.PrivateKey(private_key)
        self._acct = Account.privateKeyToAccount(self._pkey)

        # this holds the keys we bought (map: key_id => nacl.secret.SecretBox)
        self._keys = {}
        self._session = None
        self._running = False

    async def start_buying(self, session, session_details):
        self._session = session
        self._running = True

        self.log.info('Start buying from consumer delegate address {address} (public key 0x{public_key}..)',
                      address=self._acct.address,
                      public_key=binascii.b2a_hex(self._pkey.public_key[:10]).decode())

        channel_info = await session.call('xbr.marketmaker.lookup_payment_channel', self._acct.address)

        if not channel_info or not channel_info.get('id', None):
            raise Exception('no payment channel found')
        if channel_info['status'] != 'open':
            raise Exception('payment channel not open')
        if not channel_info.get('balance', None):
            raise Exception('no positive balance in payment channel')

        self._channel = channel_info['id']
        self._channel_seq = channel_info['seq']
        self._balance = channel_info['balance']

        return self._balance

    async def unwrap(self, key_id, enc_ser, ciphertext):
        assert(enc_ser == 'cbor')

        # if we don't have the key, buy it!
        if key_id not in self._keys:
            # mark the key as currently being bought already (the location of code here is multi-entrant)
            self._keys[key_id] = False

            # call the market maker to buy the key
            amount = 35
            balance = 0

            self._channel_seq += 1

            # FIXME: compute actual kecchak256 based signature
            signature = b'\x00' * 64

            # call the market maker to buy the key
            #   -> channel_id, channel_seq, key_id, amount, balance, signature
            key = await self._session.call('xbr.marketmaker.buy',
                                           self._channel,
                                           self._channel_seq,
                                           key_id,
                                           amount,
                                           balance,
                                           signature)

            # remember the key, so we can use it to actually decrypt application payload data
            self._keys[key_id] = nacl.secret.SecretBox(key)
            self.log.info('Key {key_id} bought!', key_id=uuid.UUID(bytes=key_id))

        # if the key is already bein bought, wait until the one buying string of execution has succeeded and done
        while self._keys[key_id] == False:
            self.log.info('Waiting for key {key_id} currently being bought ..', key_id=uuid.UUID(bytes=key_id))
            await sleep(.2)

        # now that we have the secret key, decrypt the event application payload
        try:
            message = self._keys[key_id].decrypt(ciphertext)
        except nacl.exceptions.CryptoError as e:
            # Decryption failed. Ciphertext failed verification
            raise RuntimeError('unwrapping XBR payload failed ({})'.format(e))

        try:
            payload = cbor2.loads(message)
        except cbor2.decoder.CBORDecodeError as e:
            # premature end of stream (expected to read 4187 bytes, got 27 instead)
            raise RuntimeError('unwrapping XBR payload failed ({})'.format(e))

        return payload
