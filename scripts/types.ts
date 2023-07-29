export type Address = `0x${string}`

export type AcceptedAsset = 'USDC' | 'USDT' | 'WETH' | 'WBTC'
export enum AcceptedAssetEnum {
  USDC = 'USDC',
  USDT = 'USDT',
  WETH = 'WETH',
  WBTC = 'WBTC',
}
// the minimal intersection of LendingToken and ServiceAsset
export interface MinimalToken {
  name: keyof typeof AcceptedAssetEnum
  coingeckoId: string
  iconName: string
  decimals: number
  tokenAddress: Address
  oracleAddress: Address
  initialPriceForIthil: string
  callOptionAddress: Address
  vaultAddress: Address
}

export interface LendingToken extends MinimalToken {
  vaultAddress: Address
}

export interface Replacement {
  slot: number
  from: number
  to: number
  value: string
}

export type JsonObject = Record<string, any>
