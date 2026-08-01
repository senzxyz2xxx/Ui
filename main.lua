local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/senzxyz2xxx/Ui/refs/heads/main/main.lua"))()

local Window = Library:Window({
    Title = "Senzy Hub",
    Footer = "Premium Script",
    Logo = 111116339097216
})

local Tab = Window:MakeTab({
    Title = "Example",
    Icon = 115960025411300
})

Tab:Label({
    Title = "Lorem Ipsum",
    Desc = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since 1966, when designers at Letraset and James Mosley, the librarian at St Bride Printing Library in London, took a 1914 Cicero translation and scrambled it to make dummy text for Letraset's Body Type sheets. It has survived not only many decades, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised thanks to these sheets and more recently with desktop publishing software like Aldus PageMaker and Microsoft Word including versions of Lorem Ipsum."
})

Tab:Toggle({
    Title = "Toggle",
    Desc = "Lorem Ipsum is simply dummy text of the printing and typesetting.",
    Value = false,
    Callback = function(v)
        print("Toggle:", v)
    end
})

Tab:Button({
    Title = "Button",
    Desc = "Lorem Ipsum is simply dummy text of the printing and typesetting.",
    Callback = function()
        print("Click!")
    end
})

Tab:Textbox({
    Title = "Textbox",
    Desc = "Lorem Ipsum is simply dummy text of the printing and typesetting.",
    Value = "ID0456",
    ClearOnFocus = true,
    Callback = function(v)
        print("Toggle:", v)
    end
})

Tab:Slider({
    Title = "Slider",
    Desc = "Lorem Ipsum is simply dummy text of the printing and typesetting.",
    Value = 25,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Callback = function(value)
        print(value)
    end,
})

Tab:Dropdown({
    Title = "Normal Dropdown",
    Value = "Apple",
    List = { "Apple", "Banana", "You", '*#*#***##*#**#', "AJSJASJASJAS", "AKSKAKSKKSKAKSAKSKASKAKSKASKAKSKAKSAKSKAKSKASKASsaasasasasas" },
    Callback = function(Value)
        print(Value)
    end,
})

Tab:Dropdown({
    Title = "Multi Dropdown",
    Value = {"Apple", "Banana"},
    List = { "Apple", "Banana", "You", '*#*#***##*#**#', "AJSJASJASJAS", "AKSKAKSKKSKAKSAKSKASKAKSKASKAKSKAKSAKSKAKSKASKASsaasasasasas" },
    Callback = function(Value)
        print(Value)
    end,
})

Window:MakeTab({
    Title = "Example",
    Icon = 115960025411300
})

Tab:Navative() -- Select Tab
