# Writing Tests

## Token and ETH values

Ethereum uses `uint256` for all numbers, whereas JavaScript uses IEEE `double` for all numbers.

However, `double` can only represent a subset of the integers that can be represented by `uint256`.

Hence, Web3 uses a big number type `BN`:

```console
$ node
> const web3 = require('web3');
undefined
> const BN = web3.utils.BN;
undefined
> const x1 = web3.utils.toWei('200', 'ether');
undefined
> x1
'200000000000000000000'
> const x2 = new BN(x1);
undefined
> x2
<BN: ad78ebc5ac6200000>
> x2.toString()
'200000000000000000000'
> x1 == x2
true
> const x3 = new BN('' + 200*10**18);
undefined
> x3.toString()
'200000000000000000000'
> x1 == x3
true
>
```
