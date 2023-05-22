/** This abomination quickly hacked together by KyleK29
  * To use, copy/paste the script into a browser injection plugin like on the JavaScript portion:
  * https://chrome.google.com/webstore/detail/user-javascript-and-css/nbhcbdghjpllgmfilhnhkllmkecfmpld
  * And configure to auto-run when the page loads.
  *
  * Date: 2023/05/22
  * Support: None
  * Author: Kyle Kimsey
  * Code Snippets: Credit(s) inline.
  * 
  * Usage - Exporting:
  * 1) Setup your settings in the Ellis3dp tool.
  * 2) Click "Export" --> file is downloaded as export.json
  * 
  * Usage - Importing:
  * 1) Click "Choose File" button --> select the file you want to upload.
  * 2) Click "Import" --> Page should reload with the settings.
  * 
*/



// Add New Buttons
var container = document.querySelectorAll('div[class$="container"]');
var new_div = document.createElement('div');
new_div.className = 'save-buttons';
//new_div.textContent = 'Testing Text';
new_div.innerHTML = '<div class="save-buttons" style="display: block;position: fixed;top: 10px;left: 10px;"><form id="upload"><label for="file">File to upload</label><input type="file" id="file" accept=".json"><button>Import</button><button onclick="fileSave()">Export</button></form></div>';

container[0].appendChild(new_div);

// Get the form and file field
let form = document.querySelector('#upload');
let file = document.querySelector('#file');
let uploaded_settings;

// Listen for submit events
form.addEventListener('submit', handleSubmit);


/**
 * Handle submit events
 * @param  {Event} event The event object
 * Credit: https://gomakethings.com/how-to-upload-and-process-a-json-file-with-vanilla-js/
 */
function handleSubmit (event) {

	// Stop the form from reloading the page
	event.preventDefault();

	// If there's no file, do nothing
	if (!file.value.length) return;

	// Create a new FileReader() object
	let reader = new FileReader();

	// Setup the callback event to run when the file is read
	reader.onload = importSettings;

	// Read the file
	reader.readAsText(file.files[0]);

}

/**
 * Log the uploaded file to the console
 * @param {event} Event The file loaded event
 */
function importSettings (event) {
	let str = event.target.result;
	uploaded_settings = str;
	
	// Replace the local storage items with uploaded.
	window.localStorage.setItem("PA_SETTINGS", uploaded_settings);
	
	// Reload
	location.reload();
}

function fileSave(){
	// Set the local storage, just in case we haven't clicked the button.
	setLocalStorage();

	// Now retrieve and save
	let newSettings = window.localStorage.getItem("PA_SETTINGS");
	exportFile(newSettings, "export.json", 'text/plain');
}

function exportFile(data, filename, type) {
	// Credit: This is from StackOverflow, but I lost the link.
    var file = new Blob([data], {type: type});
    if (window.navigator.msSaveOrOpenBlob) // IE10+
        window.navigator.msSaveOrOpenBlob(file, filename);
    else { // Others
        var a = document.createElement("a"),
                url = URL.createObjectURL(file);
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        setTimeout(function() {
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);  
        }, 0); 
    }
}
