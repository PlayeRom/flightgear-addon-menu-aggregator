#
# Menu Aggregator - Add-on for FlightGear
#
# Written and developer by Roman Ludwicki (PlayeRom, SP-ROM)
#
# Copyright (C) 2025 Roman Ludwicki
#
# This is an Open Source project and it is licensed
# under the GNU Public License v3 (GPLv3)
#

#
# Dialog class for show main menu for add-ons.
#
var MenuDialog = {
    #
    # Constants:
    #
    ITEM_H: 28 + 7, # 28 button height, +7 for margins
    PADDING: 10,

    #
    # Constructor.
    #
    # @return hash
    #
    new: func {
        # Calculate height of window
        var height = (g_MenuAggregator.getMenuCount() * MenuDialog.ITEM_H) + (MenuDialog.PADDING * 2);

        var obj = {
            parents: [
                MenuDialog,
                PersistentDialog.new(
                    width: 250,
                    height: height,
                    title: "Add-ons Menu",
                    resize: true,
                ),
            ],
        };

        # Let the parent know who their child is.
        call(PersistentDialog.setChild, [obj, MenuDialog], obj.parents[1]);

        obj._mouseX = 0;
        obj._mouseY = 0;

        obj._createLayout();

        return obj;
    },

    #
    # Destructor.
    #
    # @return void
    # @override PersistentDialog
    #
    del: func {
        call(PersistentDialog.del, [], me);
    },

    #
    # Show the dialog.
    #
    # @return void
    # @override PersistentDialog
    #
    show: func {
        g_SubMenuDialog.hide();



        call(PersistentDialog.show, [], me);
    },

    #
    # Hide the dialog.
    #
    # @return void
    # @override PersistentDialog
    #
    hide: func {
        call(PersistentDialog.hide, [], me);
    },

    #
    # @return hash
    #
    setPositionByMouse: func {
        me._mouseX = getprop('/devices/status/mice/mouse/x') or 35;
        me._mouseY = getprop('/devices/status/mice/mouse/y') or 35;
        me._window.setPosition(me._mouseX, me._mouseY);

        return me;
    },

    #
    # @return void
    #
    _createLayout: func {
        me._vbox.setContentsMargins(me.PADDING, me.PADDING, me.PADDING, me.PADDING);

        foreach (var addonMenu; g_MenuAggregator.getMenus()) {
            foreach (var menu; addonMenu.menus) {
                var button = canvas.gui.widgets.Button.new(me._group)
                    .setText(menu.label)
                    .setEnabled(menu.enabled);

                func {
                    var addonName = addonMenu.name;
                    var items = menu.items;
                    button.listen("clicked", func {
                        me.hide();
                        g_SubMenuDialog.show(addonName, items, me._mouseX, me._mouseY);
                    });
                }();

                me._vbox.addItem(button);
            }
        }
    },
};
