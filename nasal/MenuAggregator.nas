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
# The class reads the menu from all add-ons and store it in its data structure,
# then removes the menu items from all add-ons.
#
var MenuAggregator = {
    #
    # Constructor.
    #
    # @return hash
    #
    new: func {
        var obj = {
            parents: [
                MenuAggregator,
            ],
        };

        obj._menus = [];

        obj._aggregate();
        obj._removeMenus();
        obj._overrideGuiEnableMenu();

        MultiKeyCmd.new().add(obj._menus);

        obj._printLogMenuStructure();

        return obj;
    },

    #
    # Destructor.
    #
    # @return void
    #
    del: func {
        #
    },

    #
    # @return vector
    #
    getMenus: func {
        return me._menus;
    },

    #
    # @return int
    #
    getMenuCount: func {
        var count = 0;
        foreach (var addon; me._menus) {
            count += size(addon.menus);
        }

        return count;
    },

    #
    # Aggregate all add-ons menu to own structure.
    #
    # @return void
    #
    _aggregate: func {
        foreach (var addon; addons.registeredAddons()) {
            var addonMenu = me._loadMenuBarItemsXml(addon);
            if (addonMenu) {
                append(me._menus, addonMenu);
            }
        }
    },

    #
    # @param  ghost  addon  The addons.Addon object.
    # @return hash|nil
    #
    _loadMenuBarItemsXml: func(addon) {
        if (addon.id == g_Addon.id) {
            return nil; # ignore yourself
        }

        var menuNode = io.read_properties(addon.basePath ~ '/addon-menubar-items.xml');
        if (menuNode == nil) {
            return nil;
        }

        var menuBarItems = menuNode.getChild('menubar-items');
        if (menuBarItems == nil) {
            return nil;
        }

        var addonMenu = {
            id: addon.id,
            name: addon.name,
            menus: [],
        };

        foreach (var menuXml; menuBarItems.getChildren('menu')) {
            if (menuXml == nil) {
                continue;
            }

            var menu = {
                label  : me._readValue(menuXml, 'label', ''),
                name   : me._readValue(menuXml, 'name', nil),
                enabled: me._readValue(menuXml, 'enabled', true),
                items  : [],
            };

            foreach (var itemXml; menuXml.getChildren('item')) {
                if (itemXml == nil) {
                    continue;
                }

                var item = {
                    label   : me._readValue(itemXml, 'label', ''),
                    name    : me._readValue(itemXml, 'name', nil),
                    enabled : me._readValue(itemXml, 'enabled', true),
                    bindings: [],
                };

                foreach (var bindingXml; itemXml.getChildren('binding')) {
                    if (bindingXml == nil) {
                        continue;
                    }

                    var binding = {
                        command: nil,
                        params: {},
                    };

                    foreach (var bindItemXml; bindingXml.getChildren()) {
                        if (bindItemXml == nil) {
                            continue;
                        }

                        if (bindItemXml.getName() == 'command') {
                            binding.command = bindItemXml.getValue();
                        } else {
                            var value = bindItemXml.getValue();
                            if (isstr(value)) {
                                value = string.trim(value);
                            }

                            binding.params[bindItemXml.getName()] = value;
                        }
                    }

                    append(item.bindings, binding);
                }

                append(menu.items, item);
            }

            append(addonMenu.menus, menu);
        }

        return addonMenu;
    },

    #
    # @param  ghost  node  Parent node.
    # @param  string  tag  Child tag name to read.
    # @param  scalar|nil  default  Default value if child not exists.
    # @return scalar|nil
    #
    _readValue: func(node, tag, default = nil) {
        var childNode = node.getChild(tag);
        if (childNode != nil) {
            return tag == 'enabled'
                ? childNode.getBoolValue()
                : childNode.getValue();
        }

        return default;
    },

    #
    # @return void
    #
    _removeMenus: func {
        var redrawNeeded = false;

        foreach (var addonMenu; me._menus) {
            foreach (var menuItem; addonMenu.menus) {
                foreach (var menuNode; props.globals.getNode('/sim/menubar/default').getChildren('menu')) {
                    var label = menuNode.getChild('label');
                    if (label != nil and label.getValue() == menuItem.label) {
                        me._updateEnabledStateBeforeRemove(menuNode, menuItem);

                        menuNode.remove();
                        redrawNeeded = true;
                    }
                }
            }
        }

        if (redrawNeeded) {
            fgcommand("gui-redraw");
        }
    },

    #
    # Update enabled state
    #
    # @param  ghost  menuNode
    # @param  hash  menuItem
    # @return void
    #
    _updateEnabledStateBeforeRemove: func(menuNode, menuItem) {
        foreach (var itemNode; menuNode.getChildren('item')) {
            var labelNode = itemNode.getChild('label');
            var enabledNode = itemNode.getChild('enabled');

            if (enabledNode != nil and labelNode != nil) {
                foreach (var item; menuItem.items) {
                    if (item.label == labelNode.getValue()) {
                        item.enabled = enabledNode.getBoolValue();
                        break;
                    }
                }
            }
        }
    },

    #
    # @return void
    #
    _overrideGuiEnableMenu: func {
        gui.menuEnable = func(searchName, state) {
            # Fist search in my structure
            var namespace = globals['__addon[org.flightgear.addons.MenuAggregator]__'];
            if (namespace.g_MenuAggregator != nil) {
                namespace.g_MenuAggregator.menuEnable(searchName, state);
            }

            var menubar = props.globals.getNode("/sim/menubar/default");
            if (menubar == nil) {
                return;
            }

            foreach (var menu; menubar.getChildren("menu")) {
                foreach (var name; menu.getChildren("name")) {
                    if (name.getValue() == searchName) {
                        menu.getNode("enabled").setBoolValue(state);
                    }
                }
                foreach (var item; menu.getChildren("item")) {
                    foreach (var name; item.getChildren("name")) {
                        if (name.getValue() == searchName) {
                            item.getNode("enabled").setBoolValue(state);
                        }
                    }
                }
            }
        };
    },

    #
    # @param  string  searchName  Menu name.
    # @param  bool  state
    # @return void
    #
    menuEnable: func(searchName, state) {
        foreach (var addon; me._menus) {
            foreach (var menu; addon.menus) {
                if (menu.name == searchName) {
                    menu.enabled = state;
                }

                foreach (var item; menu.items) {
                    if (item.name == searchName) {
                        item.enabled = state;
                    }
                }
            }
        }
    },

    #
    # @return void
    #
    _printLogMenuStructure: func {
        if (!g_isDevMode) {
            return;
        }

        Log.print('------------------------------------------');

        foreach (var addon; me._menus) {
            Log.print('addon.id = ', addon.id);
            Log.print('addon.name = ', addon.name);

            forindex (var i; addon.menus) {
                var menu = addon.menus[i];

                Log.print('addon.menu[', i, '].label = ', menu.label);
                Log.print('addon.menu[', i, '].name = ', (menu.name or ''));
                Log.print('addon.menu[', i, '].enabled = ', menu.enabled);

                forindex (var j; menu.items) {
                    var item = menu.items[j];

                    Log.print('addon.menu[', i, '].items[', j, '].label = ', item.label);
                    Log.print('addon.menu[', i, '].items[', j, '].enabled = ', item.enabled);
                    Log.print('addon.menu[', i, '].items[', j, '].name = ', (item.name or ''));

                    forindex (var k; item.bindings) {
                        var binding = item.bindings[k];

                        Log.print('addon.menu[', i, '].items[', j, '].bindings[', k, '].command = ', binding.command);

                        foreach (var param; keys(binding.params)) {
                            Log.print('addon.menu[', i, '].items[', j, '].bindings[', k, '].params[', param ,'] = ', binding.params[param]);
                        }
                    }
                }
            }

            Log.print('------------------------------------------');
        }
    },
};
