

TextBox = Core.class(Sprite)

function TextBox:init(options)
    -- default options
  	local props = {
    x           = 0,
    y           = 0,
    width       = 256, -- constrain width of TextBox to this
    linePadding = 3, -- pixel gap between text lines
    color       = 0xe0e0e0, -- default text color
    font        = Font:getDefault(),
    text        = "",
  }

  -- overwrite default options
  if options then
    for key, value in pairs(options) do
      props[key]= value
    end
  end
  self.props = props

  -- we only need one actual TextField that we will reuse to render our TextBox
  local brush = TextField.new(props.font, "")
  self.brush = brush

  self:redraw()
end

-- set new text and redraw
function TextBox:setText(text)
  local props = self.props
  props.text = text

  self:redraw()
end

-- set new font and redraw
function TextBox:setFont(font)
  local props = self.props
  props.font = font

  self:redraw()
end

-- redraw the textbox
function TextBox:redraw()
  local props = self.props
  local font = props.font

  -- discard any previous imagery
  if self:getNumChildren() > 0 then
    self:removeChildAt(1)
  end

  -- calculate various offsets
  local lineHeight = font:getLineHeight()
  local actualHeight = lineHeight + props.linePadding -- line height + padding
  self.lineHeight = lineHeight
  self.actualHeight = actualHeight

  -- split and format text
  local lines = self:splitText(props.text, font, props.width)
  self.lines = lines

  -- create a blank canvas where we will render our text
  local canvas = RenderTarget.new(props.width, (#lines + 1) * actualHeight)
  self.canvas = canvas

  local brush = self.brush

  -- render text to canvas
  for i = 1, #lines do
    local line = lines[i]
    local words = line.words
    for w = 1, #words do
      local word = words[w]
      brush:setText(word.word)
      brush:setTextColor(word.color)
      brush:setPosition(word.x + line.x, i * actualHeight)
      canvas:draw(brush)
      --print(string.format("word=%s, x=%d, 0x%06x", word.word, word.x, word.color))
    end
  end

  -- create bitmap to display
  local bitmap = Bitmap.new(canvas) -- our canvas is the texture)
  bitmap:setPosition(props.x, props.y)

  self:addChild(bitmap)
end

-- recolor a single matching word or all matching word if "all = true"
function TextBox:recolor(text, color, all)
  local brush = self.brush
  local canvas = self.canvas

  local lineHeight = self.lineHeight
  local actualHeight = self.actualHeight

  local lines = self.lines
  for i = 1, #lines do
    local line = lines[i]
    local words = line.words
    for j = 1, #words do
      local word = words[j]
      if word.word == text then
        canvas:clear(0x000000, 0, word.x + line.x, i * actualHeight - lineHeight, word.width, actualHeight) -- clear area where word was
        word.color = color
        brush:setText(word.word)
        brush:setTextColor(color)
        brush:setPosition(word.x + line.x, i * actualHeight)
        canvas:draw(brush) -- draw word
        if not all then
          return
        end
      end
    end
  end
end

-- this does the heavy lifting, splitting and formatting text lines and words
function TextBox:splitText(text, font, maxWidth)
  local props = self.props

  local spaceWidth = font:getAdvanceX(" ")

  local words = {}
  local lines = {}
  local wordList = {}

  -- split text into words (space separated)
  local smatch = string.gmatch
  local pattern = '([^ ]+)'
  for str in smatch(text, pattern) do
    words[#words + 1] = str
  end

  local i = 1 -- which word we are currently processing
  local x = 0 -- the x offset for any line of text
  local lineWidth = 0 -- total width of text in pixels
  local color = props.color -- initial color
  local align = "left" -- current alignment
  local line = ""

  local function newLine()
    -- calculate offset for aligned text
    if align == "left" then
      x = 0
    elseif align == "right" then
      x = maxWidth - lineWidth
    elseif align == "center" then
      x = (maxWidth * 0.5) - (lineWidth * 0.5)
    end
	
    lines[#lines + 1] = {
      color = color, 
      text = line, 
      align = align, 
      width = font:getAdvanceX(line), 
      words = wordList, 
      x = x,
    }

    lineWidth = 0
    line = ""
    wordList = {}
    i = i + 1
  end

  local done = false

  repeat
    local word = words[i]

    if word == "#n#" then
      -- process line feed    
      newLine()

    elseif word == "#color#" then
      -- process text color change
      color = tonumber(words[i + 1])
      i = i + 2

    elseif word == "#align#" then
      -- process text alignment
      align = words[i + 1]
      i = i + 2

    else
      -- process a normal word
      local wordWidth = font:getAdvanceX(word)

      local w = {
        word = word,
        width = wordWidth,
        x = lineWidth,
        color = color,
      }

      if lineWidth + wordWidth + spaceWidth >= maxWidth then
        -- container width exceeded, create a new line but skip back one word because it needs to appear on the next line
		i = i - 1
        newLine()

      else
        -- process word normally
        wordList[#wordList + 1] = w
        line = line .. " " .. word
        lineWidth = lineWidth + wordWidth + spaceWidth
        i = i + 1
      end
    end

    if i > #words then
      -- all words processed, append the last line and set exit condition
      newLine()
      done = true
    end

  until done

  return lines
end
