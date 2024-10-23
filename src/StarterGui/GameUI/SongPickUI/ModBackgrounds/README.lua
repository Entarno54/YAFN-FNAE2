--[==[

| How To Make A Background For Your Mod |

Inside of this folder will contain the names/images/properties of the backgrounds for your mods.
Inside this folder you will make a folder and name it the name that you want to call your background. Just as an example will we use "Circles"
To add the image inside of the folder you will create a "StringValue" and name it "Image". Inside of the properties you will set the value to be
whatever the image id is for the image in this case it will be "rbxassetid://14533793691".
The reason it uses a string value is because of optimization reasons.

-- List of Properties --

Image - This property should be a StringValue instance and be set to the ImageId of the background you want
Pixelated - this property should be a bool value instance and set it to true if you want to disable antialiasing for your background.
Color - This property should be a Color3Value instance and this will set the color for the foreground
Color2 - This property should be a Color3Value instance and this will set the color for the background

--]==]