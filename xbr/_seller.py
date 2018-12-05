###############################################################################
#
# Copyright (c) Crossbar.io Technologies GmbH and contributors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
###############################################################################

import os
import uuid
import binascii

import cbor2
import nacl.secret
import nacl.utils

from twisted.internet.defer import inlineCallbacks

import txaio

import zlmdb

from autobahn.twisted.util import sleep
from autobahn.wamp.types import RegisterOptions

import eth_keys
from eth_account import Account

from ._interfaces import IProvider, ISeller


class SimpleSeller(object):

    log = txaio.make_logger()

    def __init__(self, private_key, interval, price):
        """

        :param private_key:
        :param interval:
        :param price:
        """
        self._pkey = eth_keys.keys.PrivateKey(private_key)
        self._acct = Account.privateKeyToAccount(self._pkey)
        self._interval = interval
        self._price = price
        self._id = None
        self._key = None
        self._box = None
        self._archive = {}
        self._running = False
        self._rotate()

    async def start(self, session, provider_id):
        """

        :param session:
        :param provider_id:
        :return:
        """
        self._running = True

        self.log.info('Start selling from provider delegate address {address} (public key 0x{public_key}..)',
                      address=self._acct.address,
                      public_key=binascii.b2a_hex(self._pkey.public_key[:10]).decode())

        for func in [self.sell]:
            procedure = 'xbr.provider.{}.{}'.format(provider_id, func.__name__)
            await session.register(func, procedure, options=RegisterOptions(details_arg='details'))
            self.log.info('Registered {func} under {procedure}', func=func, procedure=procedure)

        from twisted.internet import reactor
        reactor.callInThread(self._run, session, self._interval, self._price)

    async def wrap(self, uri, payload):
        """

        :param uri:
        :param payload:
        :return:
        """
        data = cbor2.dumps(payload)
        ciphertext = self._box.encrypt(data)
        return self._id, 'cbor', ciphertext

    # def unwrap(self, key_id, enc_ser, ciphertext):
    #     assert(enc_ser == 'cbor')
    #     data = self.decrypt(key_id, ciphertext)
    #     return cbor2.loads(data)
    #
    # def encrypt(self, data):
    #     assert(type(data) == bytes)
    #     assert(self._box is not None)
    #     return self._id, self._box.encrypt(data)
    #
    # def decrypt(self, key_id, data):
    #     assert(type(data) == bytes)
    #     assert(key_id in self._archive)
    #     return self._archive[key_id][2].decrypt(data)

    def _rotate(self):
        self._id = os.urandom(16)
        self._key = nacl.utils.random(nacl.secret.SecretBox.KEY_SIZE)
        self._box = nacl.secret.SecretBox(self._key)
        self._archive[self._id] = (zlmdb.time_ns(), self._key, self._box)
        self.log.info('key rotated, new key_id={key_id}', key_id=uuid.UUID(bytes=self._id))

    @inlineCallbacks
    def _run(self, session, interval, price):
        while self._running:
            self._rotate()
            try:
                yield session.call('xbr.marketmaker.offer', self._id, price)
            except:
                self.log.failure()
            yield sleep(interval)

    def sell(self, key_id, buyer_pubkey, amount_paid, post_balance, signature, details=None):
        """

        :param key_id:
        :param buyer_pubkey:
        :param amount_paid:
        :param post_balance:
        :param signature:
        :param details:
        :return:
        """
        if key_id not in self._archive:
            raise RuntimeError('no such datakey')

        created, key, box = self._archive[key_id]

        # FIXME: check amount paid, post balance and signature
        # FIXME: sign transaction

        sendkey_box = nacl.public.SealedBox(nacl.public.PublicKey(buyer_pubkey,
                                                                  encoder=nacl.encoding.RawEncoder))

        encrypted_key = sendkey_box.encrypt(key, encoder=nacl.encoding.RawEncoder)

        self.log.info('Key {key_id} sold to {buyer_pubkey} (caller={caller})', key_id=key_id, caller=details.caller, buyer_pubkey=buyer_pubkey)

        return encrypted_key


ISeller.register(SimpleSeller)
IProvider.register(SimpleSeller)
