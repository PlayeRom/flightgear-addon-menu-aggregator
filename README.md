"Add-ons Menu Aggregator" for FlightGear
========================================

The "Add-ons Menu Aggregator" add-on solves the problem of increasing menu clutter in FlightGear, which occurs after installing multiple add-ons. Each add-on can add its own items to the main menu, causing it to become very large and, at low resolutions, extend beyond the screen. This makes it difficult for users to find functions related to specific add-ons, and the menu itself becomes unreadable.

The "Add-ons Menu Aggregator" automatically aggregates menu entries from all installed add-ons and places them into one common menu item – "Add-ons." Each add-on receives its own submenu here, containing its original items while maintaining full functionality and layout.

## Advantages

* **Menu organization** – all add-ons are gathered in one place.
* **Easier navigation** – quick access to individual add-on functions without having to search through the entire menu.
* **Compatibility** – the add-on does not modify the functionality of other add-ons.
* **Automatic operation** – after installation, it requires no configuration; it automatically detects available add-ons and their menu positions.
* **Clarity** – even with a large number of add-ons installed, FlightGear's main menu remains clear and consistent.

## Disadvantages

* You need to make 1 more click to perform an action from the add-on menu. See the [Keyboard shortcuts](#keyboard-shortcuts) section in this document.

## How it works

When FlightGear starts, this add-on scans all installed extensions (add-ons) and captures their menu definitions. It then creates a new "Add-ons" section in the main menu, grouping all found entries by source. The original add-ons menu items are then removed from the FlightGear menu bar. All original actions (Nasal commands, XML commands, etc.) continue to function.

Clicking "Add-ons" in main menu will open a submenu with items from all add-ons that would add items to the main menu. The order of these items matches the order in the add-ons list in the Launcher. Clicking on one of the main items then opens a dialog box with menu items for that specific add-on.

## Keyboard shortcuts

Because this add-on adds one extra click to the add-on's action, it includes multi-key commands. The basic command is:

`:m` `Enter`, which opens the main add-on menu.

You can also launch the menu for a specific add-on. Multi-key commands for specific add-ons always contain two additional characters and are built dynamically based on the following rules:

1. If the add-on has at least two words in its name, the first characters of those two words are used.
2. If the add-on has one word in its name, the first two characters of that word are used.

Examples:

* `:mwr` – opens the "Which Runway" add-on menu.
* `:mlo` – opens the "Logbook" add-on menu, etc.

To see suggestions while typing a multi-key command, press the `Tab` key.

Dialog boxes also have their own keyboard shortcuts. Each menu item can be activated using the keys `1`-`9` and `0`. The `Esc` key closes the menu window.
