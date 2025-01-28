# Blackmarket Script

A QBCore blackmarket script providing an illegal vendor that sells contraband items.

## Features

- Dynamic vendor location that changes periodically
- Server synced inventory and stock management
- Configurable item categories and prices
- Random price ranges for items
- Police interaction system
- Arrest mechanic with timeout
- Alphabetically sorted categories and items
- Target integration for easy interaction
- Support for unique items with info
- Number formatting for prices/stock

## Requirements

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target)
- [qb-menu](https://github.com/qbcore-framework/qb-menu)
- [qb-input](https://github.com/qbcore-framework/qb-input)

## Installation

1. Download the script
2. Place `sg-blackmarket` into your `resources` folder or `[sg]` directory
3. Add `ensure sg-blackmarket` to your server.cfg (after qb-core and dependencies)
4. Configure options in `config.lua` to your liking
5. Restart your server

## Configuration

All configuration options can be found in the `config.lua` file.

Key options:
- `Config.Items` - Set up item categories, prices, and stock levels
- `Config.Locations` - Configure possible vendor spawn locations
- `Config.Police` - Set up police job requirements and arrest timeout
- `Config.ResetDays` - Configure how often vendor changes location
- `Config.Ped` - Customize vendor appearance and animations

## Usage

1. Find the current blackmarket vendor location
2. Interact using the target system to:
   - Browse and purchase items (for civilians)
   - Arrest the vendor (for police)
3. Vendor relocates after arrest or configured days

## Credits

- [Nicky](https://forum.cfx.re/u/Sanriku)
- [SG Scripts Discord](https://discord.gg/uEDNgAwhey)



## Version History

### v1.1.1 Update:
Updated:
- Moved `Config.Locations` to `Config.Ped.locations` for better organization
- Updated prints in `setupShopItems()` when `Debug.Config` enabled

Fixed:
- Ped location not getting the proper table values

Files Changed:
- fxmanifest.lua - version number
- config.lua - `Config.Locations` moved to `Config.Ped.locations`
- server/server.lua - `setupShopItems()` and `getOrCreatePedData()` functions

### v1.1.0 Update:
Fixed:
- Corrected info table when not present on config

Added:
- New Config Table: `Config.WeaponSerialNumbers`
  - Allow the script to create new serial numbers for weapons purchased
  - Adjust: Length, SN Prefix, If the SN is scratched, and how many times
- New Function: `generateSerialNumber()`
  - Handles creating a SN for a weapon when purchased

Files Changed:
- fxmanifest - version number
- config.lua - new config option, `Config.WeaponSerialNumbers`, added to lines 48-58
- server/main.lua - replace `'sg-blackmarket:server:purchaseItem'` callback and add new `generateSerialNumber()` function