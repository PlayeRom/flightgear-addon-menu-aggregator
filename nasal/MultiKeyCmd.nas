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
# Add multi-key command to open add-ons menu.
#
var MultiKeyCmd = {
    #
    # Constructor.
    #
    # @return hash
    #
    new: func {
        var obj = {
            parents: [
                MultiKeyCmd,
            ],
        };

        obj._firstChar = 'm';

        obj._desc = {};

        return obj;
    },

    #
    # @param  vector  menus
    # @return void
    #
    add: func(menus) {
        me._desc = {};

        var isReloadNeeded = false;

        forindex (var index; menus) {
            var addon = menus[index];
            var sequence = me._getSequencyByAddonName(addon.name);
            if (sequence == nil) {
                continue;
            }

            if (size(addon.menus) and size(addon.menus[0].items)) {
                # Simplification: if an addon has more items in the main menu,
                # only the first one will receive the multi-key
                me._addMultiKey(addon.name, sequence, index);
                isReloadNeeded = true;
            }
        }

        if (isReloadNeeded) {
            fgcommand('nasal-reload', props.Node.new({ module: 'multikey' }));
        }
    },

    #
    # Extracts a 2-character sequence from the add-on name
    #
    # @param  string  name  Add-on name.
    # @return string|nil
    #
    _getSequencyByAddonName: func(name) {
        name = string.replace(name, '_', ' ');
        name = string.lc(name);

        var parts = split(' ', name);

        if (size(parts) >= 2) {
            return chr(parts[0][0]) ~ chr(parts[1][0]);
        }

        if (size(name) >= 2) {
            return chr(name[0]) ~ chr(name[1]);
        }

        return nil;
    },

    #
    # Add multi-key command to open add-on menu.
    #
    # @param  string  addonName
    # @param  string  sequence  Multi-key sequence string.
    # @param  int  index  Add-on index in menu structure.
    # @param  bool  withExit
    # @return string
    #
    _addMultiKey: func(addonName, sequence, index, withExit = true) {
        Log.alert('MultiKeyCmd, adding multi-key: ', sequence);

        var path = '/input/keyboard/multikey/key[' ~ me._firstChar[0] ~ ']';

        for (var i = 0; i < size(sequence); i += 1) {
            var currentSeq = substr(sequence, 0, i + 1);
            if (!contains(me._desc, currentSeq)) {
                me._desc[currentSeq] = addonName;
            } else {
                me._desc[currentSeq] ~= ', ' ~ addonName;
            }

            path ~= '/key[' ~ sequence[i] ~ ']';
            setprop(path ~ '/name', chr(sequence[i]));
            setprop(path ~ '/desc', me._desc[currentSeq]);
        }

        if (withExit) {
            setprop(path ~ '/exit', '');
        }

        setprop(path ~ '/binding/command', 'nasal');
        setprop(
            path ~ '/binding/script',
            "globals['__addon[org.flightgear.addons.MenuAggregator]__'].g_SubMenuDialog.showByMultiKey(" ~ index ~ ");"
        );

        return path;
    },
};
