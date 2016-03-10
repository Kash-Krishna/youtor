#
# gtkui.py
#
# Copyright (C) 2009 SharkByte <Kash@SharkByte.com>
#
# Basic plugin template created by:
# Copyright (C) 2008 Martijn Voncken <mvoncken@gmail.com>
# Copyright (C) 2007-2009 Andrew Resch <andrewresch@gmail.com>
# Copyright (C) 2009 Damien Churchill <damoxc@gmail.com>
#
# Deluge is free software.
#
# You may redistribute it and/or modify it under the terms of the
# GNU General Public License, as published by the Free Software
# Foundation; either version 3 of the License, or (at your option)
# any later version.
#
# deluge is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with deluge.    If not, write to:
# 	The Free Software Foundation, Inc.,
# 	51 Franklin Street, Fifth Floor
# 	Boston, MA  02110-1301, USA.
#
#    In addition, as a special exception, the copyright holders give
#    permission to link the code of portions of this program with the OpenSSL
#    library.
#    You must obey the GNU General Public License in all respects for all of
#    the code used other than OpenSSL. If you modify file(s) with this
#    exception, you may extend this exception to your version of the file(s),
#    but you are not obligated to do so. If you do not wish to do so, delete
#    this exception statement from your version. If you delete this exception
#    statement from all source files in the program, then also delete it here.
#

import gtk

from deluge.log import LOG as log
from deluge.ui.client import client
from deluge.plugins.pluginbase import GtkPluginBase
import deluge.component as component
import deluge.common

from twisted.internet import defer

from common import get_resource

import os


class AutoForward(gtk.Dialog):
    """Input to start autoforwarding"""
    
    def __init__(self):
        super(AutoForward, self).__init__(title="Start AutoForwarding",
            parent = component.get("MainWindow").window,
            flags = (gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT | gtk.DIALOG_NO_SEPARATOR),
            buttons = ("Cancel", gtk.RESPONSE_NO, "Add box", gtk.RESPONSE_YES)
        )

        self.connect("delete-event", self._on_delete_event)
        self.connect("response", self._on_response)

        ui_file = "inputWindow.ui"
        self._load_ui(ui_file)

        self.set_default_response(gtk.RESPONSE_YES)

        """ linking to buttons on the UI (P = Parameter)"""
        self.nameP = self.builder.get_object("name")
        self.nameP.set_activates_default(True)
        self.nameP.grab_focus()

        self.addrP = self.builder.get_object("address")
        self.addrP.set_activates_default(True)
        self.addrP.grab_focus()
   
    @property
    def p_name(self):
        return self.nameP.get_text()

    @property
    def p_address(self):
        return self.addrP.get_text()

    def _load_ui(self, ui_file):
        """Load content using root object from ui file """
        self.builder = gtk.Builder()
        self.builder.add_from_file(get_resource(ui_file))
        self.root = self.builder.get_object("root")
        self.get_content_area().pack_start(self.root)
        self.builder.connect_signals(self)

    def _on_delete_event(self, widget, event):
        self.deferred.callback(gtk.RESPONSE_DELETE_EVENT)
        self.destroy()

    def _on_response(self, widget, response):
        self.deferred.callback(response)
        self.destroy()

    def run(self):
        """Shows the dialog and returns a deferred object // test later"""
        self.deferred = defer.Deferred()
        self.show()
        return self.deferred


class GtkUI(GtkPluginBase):
    def enable(self):
        self.glade = gtk.glade.XML(get_resource("config.glade"))
        self.plugin_manager = component.get("PluginManager")
        self.tbar_separator = self.plugin_manager.add_toolbar_separator()
        self.tbar_aforw = self.plugin_manager.add_toolbar_button(self.AutoForwardUI,
            label="setup forwarding", stock=gtk.STOCK_HARDDISK, tooltip="start the forwarding protocol")
        
    def disable(self):
        self.plugin_manager.remove_toolbar_button(self.tbar_aforw)
        self.plugin_manager.remove_toolbar_button(self.tbar_separator)

    @defer.inlineCallbacks
    def AutoForwardUI(self, widget):
        inputWindow = AutoForward()
        response = yield inputWindow.run()

        if response == gtk.RESPONSE_YES:
            nameP = inputWindow.p_name
            addrP = inputWindow.p_address
            os.system("python forwarding.py " + addrP + " " + nameP)
            
