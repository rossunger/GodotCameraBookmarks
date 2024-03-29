extends EditorInspectorPlugin

# MIT License
#
# Copyright (c) 2023 Donn Ingle (donn.ingle@gmail.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

var InspectorToolButton = preload("inspector_button.gd")
var button_text : String


func _can_handle(object) -> bool:
	return true


func _parse_property(
	object: Object, type: Variant.Type, 
	name: String, hint_type: PropertyHint, 
	hint_string: String, usage_flags, wide: bool):
	if name.begins_with("go_"):
		var s = str(name.split("go_")[1])
		s = s.replace("_", " ")
		s = "Press to %s" % s
		add_custom_control(
			InspectorToolButton.new(object, s))
		return true #Returning true removes the built-in editor for this property

	return false # else leave it
