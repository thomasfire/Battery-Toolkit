import Foundation

public struct BTPowerState {
    private static var chargingDisabled = false
    private static var powerDisabled    = false

    public static func initPowerState() {
        let chargeEnabled = SMCPowerKit.isChargingEnabled()
        BTPowerState.chargingDisabled = !chargeEnabled
        if chargeEnabled {
            //
            // Sleep must always be disabled when charging.
            //
            SleepKit.disableSleep()
        }
        
        let powerEnabled = SMCPowerKit.isPowerAdapterEnabled()
        BTPowerState.powerDisabled = !powerEnabled
        if !powerEnabled {
            //
            // Sleep must always be disabled when external power is disabled.
            //
            SleepKit.disableSleep()
        }
    }

    public static func adapterSleepPreferenceToggled() {
        //
        // If power is disabled, toggle sleep.
        //
        if BTPowerState.powerDisabled {
            if !BTSettings.adapterSleep {
                SleepKit.disableSleep()
            } else {
                SleepKit.restoreSleep()
            }
        }
    }

    public static func disableCharging() {
        if BTPowerState.chargingDisabled {
            return
        }

        let result = SMCPowerKit.disableCharging()
        if !result {
            // FIXME: Handle error
            return
        }
        
        SleepKit.restoreSleep()
        
        BTPowerState.chargingDisabled = true
    }
    
    public static func enableCharging() {
        if !BTPowerState.chargingDisabled {
            return
        }

        let result = SMCPowerKit.enableCharging()
        if !result {
            // FIXME: Handle error
            return
        }
        
        SleepKit.disableSleep()
        
        BTPowerState.chargingDisabled = false
    }

    public static func disablePowerAdapter() {
        if BTPowerState.powerDisabled {
            return
        }

        if !BTSettings.adapterSleep {
            SleepKit.disableSleep()
        }

        let result = SMCPowerKit.disablePowerAdapter()
        if !result {
            if !BTSettings.adapterSleep {
                SleepKit.restoreSleep()
            }
            // TODO: Handle error
            return
        }

        BTPowerState.powerDisabled = true
    }

    public static func enablePowerAdapter() {
        if !BTPowerState.powerDisabled {
            return
        }

        let result = SMCPowerKit.enablePowerAdapter()
        if !result {
            // TODO: Handle error
            return
        }
        
        if !BTSettings.adapterSleep {
            SleepKit.restoreSleep()
        }

        BTPowerState.powerDisabled = false
    }
}
