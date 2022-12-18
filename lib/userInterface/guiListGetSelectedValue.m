function [selectedValue]=guiListGetSelectedValue(listbox)
contents = cellstr(get(listbox,'String'));
selectedValue=contents{get(listbox,'Value')};