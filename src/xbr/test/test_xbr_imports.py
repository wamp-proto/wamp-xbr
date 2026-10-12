###############################################################################
#
# The MIT License (MIT)
#
# Copyright (c) typedef int GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################

# Import smoke tests: xbr must import completely, together with its native
# dependencies, on every supported Python implementation (CPython and PyPy).
#
# xbr/__init__.py catches ImportError and sets HAS_XBR = False instead of
# failing, and most tests here are skipped when HAS_XBR is false. A broken
# dependency (e.g. bitarray 3.12.0 on PyPy, see wamp-xbr#209 and
# https://github.com/ilanschnell/bitarray/issues/257) would therefore turn the
# test suite green-by-skipping, while crossbar fails at runtime.

import unittest

# the names crossbar imports from xbr at runtime
CROSSBAR_IMPORTS = {
    "xbr": [
        "EIP712AuthorityCertificate",
        "FbsObject",
        "FbsRepository",
        "FbsSchema",
        "UserKey",
        "is_address",
        "is_block_number",
        "is_bytes16",
        "is_chain_id",
        "is_cs_pubkey",
        "is_signature",
        "make_w3",
        "pack_uint256",
        "parse_certificate_chain",
        "recover_eip712_api_publish",
        "recover_eip712_catalog_create",
        "recover_eip712_consent",
        "recover_eip712_market_create",
        "recover_eip712_market_join",
        "recover_eip712_market_member_login",
        "recover_eip712_member_login",
        "recover_eip712_member_register",
        "unpack_uint256",
    ],
    "xbr._schema": ["FbsRepository"],
    "xbr._secmod": ["SecurityModuleMemory"],
}


class TestImports(unittest.TestCase):
    def test_import_bitarray(self):
        import bitarray
        from bitarray import util

        self.assertTrue(util.zeros(8).count(0) == 8, bitarray.__version__)

    def test_import_eth(self):
        import eth_abi  # noqa: F401
        import eth_account  # noqa: F401
        import web3  # noqa: F401

    def test_has_xbr(self):
        from xbr import HAS_XBR

        self.assertTrue(HAS_XBR, "xbr imported without its XBR features (HAS_XBR is False)")

    def test_crossbar_imports(self):
        import importlib

        for module_name, names in CROSSBAR_IMPORTS.items():
            module = importlib.import_module(module_name)
            for name in names:
                with self.subTest(module=module_name, name=name):
                    self.assertTrue(hasattr(module, name))
