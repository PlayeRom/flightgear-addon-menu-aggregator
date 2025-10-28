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
    WINDOW_WIDTH: 250,
    PADDING: 10,

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

        # Enable correct handling of window positioning in the center of the screen.
        call(PersistentDialog.setPositionOnCenter, [], obj.parents[1]);

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
    # @return void
    # @override PersistentDialog
    #
    show: func(addonName, items) {
        me._window.setTitle(addonName ~ " Menu");

        me._recalculateWindowHeight(items);
        me._createLayout(items);

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
    # @param  vector  items
    # @return void
    #
    _recalculateWindowHeight: func(items) {
        var height = me._getHeight(items);

        me._window.setSize(me.WINDOW_WIDTH, height);

        var heightWithBar = height + me._window._title_bar_height;

        # Check whether the selector window does not go outside the screen at the bottom, if so, move it up
        var posY = me.getPosY();
        var screenH = me.getScreenHeight();
        if (screenH - posY < heightWithBar) {
            posY = screenH - heightWithBar;
            me._window.setPosition(me.getPosX(), posY);
        }
    },

    #
    # @param  vector  items
    # @return int
    #
    _getHeight: func(items) {
        var height = MenuDialog.ITEM_H;; # back button

        foreach (var item; items) {
            if (size(item.bindings)) {
                height += MenuDialog.ITEM_H;
            } else {
                if (string.match(item.label, '---*')) {
                    height += 5 + 7;
                } else {
                    height += MenuDialog.ITEM_H;
                }
            }
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

        foreach (var item; items) {
            if (size(item.bindings)) {
                var button = canvas.gui.widgets.Button.new(me._group)
                    .setText(item.label)
                    .setEnabled(item.enabled);

                func {
                    var bindings = item.bindings;
                    button.listen('clicked', func {
                        me.hide();
                        g_MenuDialog.hide();
                        foreach (var binding; bindings) {
                            fgcommand(binding.command, props.Node.new(binding.params));
                        }
                    });
                }();

                me._vbox.addItem(button);
            } else {
                if (string.match(item.label, '---*')) {
                    me._vbox.addItem(canvas.gui.widgets.HorizontalRule.new(me._group));
                } else {
                    var label = canvas.gui.widgets.Label.new(me._group)
                        .setText(item.label)
                        .setEnabled(item.enabled);

                    label.setTextAlign('center');

                    me._vbox.addItem(label);
                }
            }
        }

        var backBtn = canvas.gui.widgets.Button.new(me._group)
            .setText('< Back')
            .listen('clicked', func {
                me.hide();
                g_MenuDialog.show();
            });

        me._vbox.addItem(canvas.gui.widgets.HorizontalRule.new(me._group));
        me._vbox.addItem(backBtn);
    },
};
