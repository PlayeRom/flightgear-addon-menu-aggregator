"Add-ons Menu Aggregator" for FlightGear
=====================================

The "Add-ons Menu Aggregator" add-on solves the problem of increasing menu clutter in FlightGear, which occurs after installing multiple add-ons. Each add-on can add its own items to the main menu, causing it to become very large and, at low resolutions, extend beyond the screen. This makes it difficult for users to find functions related to specific add-ons, and the menu itself becomes unreadable.

The "Add-ons Menu Aggregator" automatically aggregates menu entries from all installed add-ons and places them into one common menu item – "Add-ons." Each add-on receives its own submenu here, containing its original items while maintaining full functionality and layout.

## Advantages

* **Menu organization** – all add-ons are gathered in one place.
* **Easier navigation** – quick access to individual add-on functions without having to search through the entire menu.
* **Compatibility** – the add-on does not modify the functionality of other add-ons.
* **Automatic operation** – after installation, it requires no configuration; it automatically detects available add-ons and their menu positions.
* **Clarity** – even with a large number of add-ons installed, FlightGear's main menu remains clear and consistent.

## How it works

When FlightGear starts, this add-on scans all installed extensions (add-ons) and captures their menu definitions. It then creates a new "Add-ons" section in the main menu, grouping all found entries by source. The original add-ons menu items are then removed from the FlightGear menu bar. All original actions (Nasal commands, XML commands, etc.) continue to function.

After selecting "Add-ons" -> "Add-ons Menu...", a new dialog box opens with the main menu items for all add-ons. The order of these items follows the order of the add-ons' list in the Launcher. Then, clicking on one of the main items opens another dialog box with the menu items for that specific add-on.
