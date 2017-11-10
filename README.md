# TextBox
A text box featuring line wrapping, alignment, and per word coloring



Text supplied to a TextBox will be wrapped automatically to a user specified width. The height will be auto generated so no need to bother with that. Text can change color word by word and you can align the text left. right, or center. You can also make new lines. Words can also have their color changed on the fly.



<b>CONTROL CODES</b>


#align# - the next word will be used to align the text ("left", "right", "center")

#color# - the next word will be used as the new brush color (0x000000 format)

#n# - will force a new line



Note that EVERYTHING must be separated by SPACES and in the expected format/order or the TextBox class will crash. Error checking could be built in.




<b>FUNCTIONS</b>


TextBox:new(options)

options (optional) is a table containing things like text, x, y, color, etc.



TextBox:SetText(text)

text - the new text to be rendered. This will force the TextBox to redraw its self.



TextBox:SetFont(font)

font - the new font to be used. This will force the TextBox to redraw its self.



TextBox:recolor(text, color, all)

text - the word that will be recolored.

color - the new color for the word.

all - if true, all occurrences of the word in the TextBox will be recolored.
