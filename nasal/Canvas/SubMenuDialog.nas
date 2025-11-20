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
# Dialog class for show specific add-on menu.
#
var SubMenuDialog = {
    #
    # Constants:
    #
    WINDOW_WIDTH: 300,
    PADDING: 10,
    ITEM_H: 28 + 7, # 28 button height, +7 for margins

    #
    # Constructor.
    #
    # @return hash
    #
    new: func {
        var obj = {
            parents: [
                SubMenuDialog,
                PersistentDialog.new(
                    width: SubMenuDialog.WINDOW_WIDTH,
                    height: 300,
                    title: "Add-ons Menu",
                    resize: true,
                ),
            ],
        };

        # Let the parent know who their child is.
        call(PersistentDialog.setChild, [obj, SubMenuDialog], obj.parents[1]);

        obj._shortcuts = {};

        obj._handleKeys();

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
    # @param  string  addonName
    # @param  vector  items
    # @param  int  posX
    # @param  int  posY
    # @return void
    # @override PersistentDialog
    #
    show: func(addonName, items, posX, posY) {
        me._window.setTitle(addonName ~ " Menu");

        me._recalculateWindowHeight(items);
        me._window.setPosition(posX, posY);
        me._createLayout(items);

        call(PersistentDialog.show, [], me);
    },

    #
    # @param  int  index  Add-on index in menu structure.
    # @return void
    #
    showByIndex: func(index) {
        var menus = g_MenuAggregator.getMenus();
        var addon = menus[index];
        var items = addon.menus[0].items; # Simplification: multi-key only activates the first menu
        var mouseX = getprop('/devices/status/mice/mouse/x') or 35;
        var mouseY = getprop('/devices/status/mice/mouse/y') or 35;

        me.show(addon.name, items, mouseX, mouseY);
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
    # @param  vector  items
    # @return void
    #
    _recalculateWindowHeight: func(items) {
        var height = me._getHeight(items);

        me._window.setSize(me.WINDOW_WIDTH, height);
    },

    #
    # @param  vector  items
    # @return int
    #
    _getHeight: func(items) {
        var height = 0;

        foreach (var item; items) {
            if (size(item.bindings)) {
                height += me.ITEM_H;
                continue;
            }

            if (string.match(item.label, '---*')) {
                height += 5 + 7;
                continue;
            }

            height += me.ITEM_H;
        }

        return height + (me.PADDING * 2);
    },

    #
    # @param  vector  items
    # @return void
    #
    _createLayout: func(items) {
        me._vbox.clear();
        me._vbox.setContentsMargins(me.PADDING, me.PADDING, me.PADDING, me.PADDING);

        me._shortcuts = {};

        var id = 1;

        foreach (var item; items) {
            if (size(item.bindings)) {
                var shortcut = id > 10
                    ? ''
                    : ' <' ~ (id == 10 ? 0 : id) ~ '>';

                var button = canvas.gui.widgets.Button.new(me._group)
                    .setText(item.label ~ shortcut)
                    .setEnabled(item.enabled)
                    .listen('clicked', me._clickedCallback(item.bindings));

                me._vbox.addItem(button);

                if (id < 11) {
                    var key = id == 10 ? 0 : id;
                    me._shortcuts[key ~ ''] = me._clickedCallback(item.bindings);
                }

                id += 1;
                continue;
            }

            if (string.match(item.label, '---*')) {
                me._vbox.addItem(canvas.gui.widgets.HorizontalRule.new(me._group));
                continue;
            }

            var label = canvas.gui.widgets.Label.new(me._group)
                .setText(item.label)
                .setEnabled(item.enabled);

            label.setTextAlign('center');

            me._vbox.addItem(label);
        }
    },

    #
    # @param  vector  bindings
    # @return func
    #
    _clickedCallback: func(bindings) {
        return func {
            me.hide();
            foreach (var binding; bindings) {
                fgcommand(binding.command, props.Node.new(binding.params));
            }
        };
    },

    #
    # Handle keydown listener for window.
    #
    # @return void
    #
    _handleKeys: func {
        me._window.addEventListener('keydown', func(event) {
            if (   event.key == '1'
                or event.key == '2'
                or event.key == '3'
                or event.key == '4'
                or event.key == '5'
                or event.key == '6'
                or event.key == '7'
                or event.key == '8'
                or event.key == '9'
                or event.key == '0'
            ) {
                if (contains(me._shortcuts, event.key)) {
                    me._shortcuts[event.key]();
                }
            }
        });
    },
};
