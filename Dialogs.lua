-----------Dialogs-----------------------------------------------------
Dialogs = {}
Dialogs.__index = Dialogs
Dialogs.type = 'Dialogs'
strCount = 0
stop = 0

function Dialogs:readStr(str,diaTxt)
  if stop == 0 then
    if strCount == 0 then
      file = io.open(diaTxt, "r")
      io.input(file)
      strCount = strCount + 1
      f = ''
    end
    while strCount<str do
      t = file:read()
      strCount = strCount + 1
    end
    t = file:read(1)
    if t ~= nil and t ~= "#" then
      f = f .. t
      io.input(file)
    end
    if t == "#" then
      strCount = strCount + 1
      if strCount > str then
        stop = 1
      end
    end
  end
  file.close()
  --create button prodolzhitj
  return f
end
