#
# Menu Aggregator Add-on for FlightGear
#
# Written and developer by Roman Ludwicki (PlayeRom, SP-ROM)
#
# Copyright (C) 2025 Roman Ludwicki
#
# This is an Open Source project and it is licensed
# under the GNU Public License v3 (GPLv3)
#

#
# Add sub-menu items to add-on menu.
#
var MainMenu = {
    #
    # Constants.
    #
    # @param  vector  menus
    # @return hash
    #
    new: func(menus) {
        var obj = {
            parents: [
                MainMenu,
            ],
            _menus: menus,
        };

        obj._mainMenuName = obj._getMainMenuName();

        obj._build();

        return obj;
    },

    #
    # Get main menu label for this add-on, read from /addon-menubar-items.xml file.
    #
    # @return string
    #
    _getMainMenuName: func {
        var menuNode = io.read_properties(g_Addon.basePath ~ '/addon-menubar-items.xml');
        if (menuNode == nil) {
            return 'none';
        }

        var menuBarItems = menuNode.getChild('menubar-items');
        if (menuBarItems == nil) {
            return 'none';
        }

        var menu = menuBarItems.getChild('menu');
        if (menu == nil) {
            return 'none';
        }

        var label = menu.getChild('name');
        if (label == nil) {
            return 'none';
        }

        return label.getValue();
    },

    #
    # Build menu items with add-ons.
    #
    # @return void
    #
    _build: func {
        var isReloadNeeded = false;

        forindex (var index; me._menus) {
            var addon = me._menus[index];

            if (size(addon.menus) and size(addon.menus[0].items)) {
                # Simplification: if an addon has more items in the main menu,
                # only the first one will receive the multi-key
                if (me._addMenu(addon.name, index)) {
                    isReloadNeeded = true;
                }
            }
        }

        if (me._addAboutMenu()) {
            isReloadNeeded = true;
        }

        if (isReloadNeeded) {
            fgcommand('gui-redraw');
        }
    },

    #
    # Add menu item to our add-on menu.
    #
    # @param  string  addonName
    # @param  int  index
    # @return bool
    #
    _addMenu: func(addonName, index) {
        var menuNode = me._getMenuNode();
        if (menuNode == nil) {
            Log.alertWarning('menu node not found');
            return false;
        }

        if (me._isMenuItemExists(menuNode, addonName)) {
            Log.alertWarning('menu item already exist');
            return false;
        }

        var data = {
            label  : addonName,
            binding: {
                command: 'nasal',
                script : "globals['__addon[" ~ g_Addon.id ~ "]__'].g_SubMenuDialog.showByIndex(" ~ index ~ ");"
            }
        };

        menuNode.addChild('item').setValues(data);

        Log.alertSuccess('the menu item "', addonName, '" has been added.');

        return true;
    },

    #
    # Add About item to menu.
    #
    # @return bool
    #
    _addAboutMenu: func {
        var menuNode = me._getMenuNode();
        if (menuNode == nil) {
            Log.alertWarning('menu node not found');
            return false;
        }

        var label = 'About...';

        if (me._isMenuItemExists(menuNode, label)) {
            Log.alertWarning('menu item already exist');
            return false;
        }

        var data = {
            label  : label,
            binding: {
                command: 'nasal',
                script : "globals['__addon[" ~ g_Addon.id ~ "]__'].g_AboutDialog.show();"
            }
        };

        menuNode.addChild('item').setValues(data);

        return true;
    },

    #
    # Get node with addon menu or nil if not found.
    #
    # @return ghost|nil
    #
    _getMenuNode: func {
        foreach (var menu; props.globals.getNode('/sim/menubar/default').getChildren('menu')) {
            var name = menu.getChild('name');
            if (name != nil and name.getValue() == me._mainMenuName) {
                return menu;
            }
        }

        return nil;
    },

    #
    # Prevent to add menu item more than once, e.g. after reload the sim by <Shift-Esc>.
    #
    # @param  ghost  menuNode
    # @param  string  label
    # @return bool
    #
    _isMenuItemExists: func(menuNode, label) {
        return me._getMenuItem(menuNode, label) != nil;
    },

    #
    # Get menu item or nil if not found.
    #
    # @param  ghost  menuNode
    # @param  string  label
    # @return ghost|nil
    #
    _getMenuItem: func(menuNode, label) {
        foreach (var item; menuNode.getChildren('item')) {
            var labelNode = item.getChild('label');
            if (labelNode != nil and labelNode.getValue() == label) {
                return item;
            }
        }

        return nil;
    },
};
