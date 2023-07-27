import { ethers } from 'hardhat'

import type { AaveService } from '../../typechain-types'
import { getDataDir, getFrontendDir, getJsonProperty, updateJsonProperty, useHardhatENV } from '../command-helpers'
import { AAVE_POOL_ON_ARBITRUM, GOVERNANCE, oneMonth } from '../config'
import { configDebitService, serviceToggleWhitelist, setCapacity } from '../contracts'
import { tokens } from '../tokens'
import { deployManagerContract } from './deployManagerContract'

useHardhatENV()

const contractJsonDir = getDataDir('contracts.json')
const frontendContractJsonDir = getFrontendDir('contracts.json')

const currentAaveServiceAddress = getJsonProperty(contractJsonDir, 'aaveService')

interface DeployAaveServiceContractProps {
  isNewDeploy: boolean
}
async function deployAaveServiceContract({ isNewDeploy }: DeployAaveServiceContractProps) {
  let aaveService: AaveService

  if (isNewDeploy) {
    const manager = await deployManagerContract({ isNewDeploy: false })
    const AaveService = await ethers.getContractFactory('AaveService')
    aaveService = await AaveService.deploy(manager.address, AAVE_POOL_ON_ARBITRUM, oneMonth)
    await aaveService.deployed()
    console.log(`AaveService contract deployed to ${aaveService.address}`)

    await configDebitService({
      manager,
      service: aaveService,
    })
  } else {
    aaveService = await ethers.getContractAt('AaveService', currentAaveServiceAddress)
    console.log(`AaveService contract instance created with this address: ${aaveService.address}`)
  }
  updateJsonProperty(contractJsonDir, 'aaveService', aaveService.address)
  updateJsonProperty(frontendContractJsonDir, 'aaveService', aaveService.address)
  return aaveService
}

// Use if (require.main === module) to check if the file is the main entry point
if (require.main === module) {
  // If it's the main entry point, execute the deployManagerContract function
  void deployAaveServiceContract({ isNewDeploy: true }).catch((error) => {
    console.error(error)
    process.exitCode = 1
  })
}

export { deployAaveServiceContract }
