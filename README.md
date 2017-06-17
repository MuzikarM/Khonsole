# Khonsole
Khonsole currently in development everything is subject to change!  
This library creates an ingame console to make game developing and debugging easier.
## Quickstart
To use this library in your kha project just add it in your libraries folder and also add it your khafile.js.  
Khonsole also uses hscript for execution of script so you have to add this dependency also.  
```javascript
let project = new Project('example-project');
project.addLibrary('Khonsole');
project.addLibrary('hscript');
resolve(project);
```
If Khonsole is available in your project, then you can just call ```Khonsole.init``` and the Khonsole will show.  
The Khonsole class is your main entry point, if you don't need to modify it in any way you can just use Khonsole as is.  
You need to call ```Khonsole.render``` to render Khonsole.
## Using Khonsole
To harness the full potential of Khonsole you can create your own commands or register your variables to use in scripts.
When inputing commands you can enforce execution of said command putting ! before the keyword, so no collisions
with variables in script happens.
