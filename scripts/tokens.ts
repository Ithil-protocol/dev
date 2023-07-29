import { type AcceptedAsset, type MinimalToken } from './types'

export const tokens: MinimalToken[] = [
  {
    name: 'USDC',
    coingeckoId: 'usd-coin',
    iconName: 'usdc',
    decimals: 6,
    tokenAddress: '0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8',
    oracleAddress: '0x50834f3163758fcc1df9973b6e91f0f0f0434ad3',
    initialPriceForIthil: '400000',
    vaultAddress: '0x',
    callOptionAddress: '0x',
    aaveCollateralTokenAddress: '0x625E7708f30cA75bfd92586e17077590C60eb4cD',
    gmxCollateralTokenAddress: '0x1aDDD80E6039594eE970E5872D247bf0414C8903',
  },
  {
    name: 'USDT',
    coingeckoId: 'tether',
    iconName: 'usdt',
    decimals: 6,
    tokenAddress: '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9',
    oracleAddress: '0x3f3f5df88dc9f13eac63df89ec16ef6e7e25dde7',
    initialPriceForIthil: '400000',
    vaultAddress: '0x',
    callOptionAddress: '0x',
    aaveCollateralTokenAddress: '0x6ab707Aca953eDAeFBc4fD23bA73294241490620',
    gmxCollateralTokenAddress: '0x1aDDD80E6039594eE970E5872D247bf0414C8903',
  },
  {
    name: 'WETH',
    coingeckoId: 'ethereum',
    iconName: 'eth',
    decimals: 18,
    tokenAddress: '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
    oracleAddress: '0x639fe6ab55c921f74e7fac1ee960c0b6293ba612',
    initialPriceForIthil: '220000000000000',
    vaultAddress: '0x',
    callOptionAddress: '0x',
    aaveCollateralTokenAddress: '0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8',
    gmxCollateralTokenAddress: '0x1aDDD80E6039594eE970E5872D247bf0414C8903',
  },
  {
    name: 'WBTC',
    coingeckoId: 'btc',
    iconName: 'btc',
    decimals: 8,
    tokenAddress: '0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f',
    oracleAddress: '0xd0c7101eacbb49f3decccc166d238410d6d46d57',
    initialPriceForIthil: '1363',
    vaultAddress: '0x',
    callOptionAddress: '0x',
    aaveCollateralTokenAddress: '0x078f358208685046a11C85e8ad32895DED33A249',
    gmxCollateralTokenAddress: '0x1aDDD80E6039594eE970E5872D247bf0414C8903',
  },
]

export const tokenMap = Object.fromEntries(tokens.map((token) => [token.name, token])) as Record<
  AcceptedAsset,
  MinimalToken
>
