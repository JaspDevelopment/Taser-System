# TASER X2 System for FiveM

A realistic TASER X2 implementation for FiveM servers, featuring cartridge management, battery levels, and detailed logging capabilities.

## Features

- Realistic TASER X2 HUD display
- Cartridge management system (2 cartridges)
- Battery level monitoring and charging
- Discord webhook integration for deployment logging
- Excessive use monitoring and alerts
- Postal code integration (if available)
- Command aliases for quick access
- Realistic incapacitation effects

## Installation

1. Download the resource
2. Place the `taser-x2` folder in your server's resources directory
3. Add `ensure taser-x2` to your server.cfg
4. Configure the `config.lua` file with your desired settings

## Configuration

Edit the `config.lua` file to customize:
- Discord webhook URL for logging
- Battery drain rate
- Maximum range
- Reload time
- Incapacitation duration
- Maximum cartridges

## Commands

- `/reloadtaser` or `/rt` - Reload TASER cartridges
- `/chargetaser` - Recharge TASER battery
- `/taserwebhook` - Test webhook connection

## Dependencies

- FiveM Base Game
- nearest-postal (optional) - For postal code logging

## Technical Details

- Uses native GTA V stungun
- Configurable range (default 25 feet)
- 10% chance of critical hit
- Automatic logging of deployments
- Excessive use warnings at 4 and 10 deployments within 10 minutes

## License

This resource is licensed under MIT License. See LICENSE file for details.

## Author

Created by Jas (GitHub)
