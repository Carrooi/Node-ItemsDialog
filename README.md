# Items dialog

Modal dialog for writing items in groups (eg. contacts).
Using [modal-dialog](https://npmjs.org/package/modal-dialog) package and is dependent on jquery.
This dialog is also instance of [EventEmitter](http://nodejs.org/api/events.html).

This dialog is completely without styles, so for styling you have to read more about [modal-dialog](https://npmjs.org/package/modal-dialog) package.

## Usage

```
var Items = require('items-dialog');
var items = new Items;

items.types = {
	facebook: 'Facebook',
	google: 'Google plus',
	skype: 'Skype'
};

items.open();
```

You have to set just object with list of types. This can be for example from your database, where keys are IDs and values
are publicly visible names.

Thane call the `open` method which can be added to some event handler (eg. click on some button).

## Default values

```
items.defaults = {
	facebook: ['david', 'george']
}
```

## Get selected data

```
var data = items.getValues();
```

This will return object which has got the same structure like `defaults` property.

## Use it in form

You can add text input into your form and connect it with items-dialog. Then after every change, data from `getValues` method
will be added into your input. These data are "stringified".

This works also in opposite direction. When this result input contains some data, they will be added into `defaults` property.

```
items.setResultElement($('#myInputInForm'));
```

## Showing summary of items

This feature is like the previous one, except one thing. You are connecting div element not text input and data are rendered
into this element.

```
items.setSummaryElement($('mySummaryElement'));
```

## Prepare component

If you want to render for example summary immediately after some setup, you have to call method `prepare`.

```
items.prepare();
```

## Own labels and texts

There is variable `labels` which holds all labels.

The simplest option is to set own labels globally.

```
var Items = require('items-dialog');

Items.labels.title = 'Add contacts';
```

or you can set it for each dialog

```
var Items = require('items-dialog');
var items = new Items;

items.labels.title = 'Add contacts';
```

### List of labels

* `title`: Title of modal dialog
* `okButton`: Button in the bottom of the modal dialog
* `addTypeHint`: "prompt" text of first text in select input (eg. Please select something)
* `help`: Text in the top of modal dialog content
* `removeType`: Title of link for removing whole type
* `writeItem`: Text in prompt dialog for writing new item in type. There you can use %s "variable" which will be replaced with selected type (eg. Please enter new item into %s type)
* `addItem`: Title of link for adding new item into type
* `editItem`: Title of link for editing item
* `removeItem`: Title of link for removing one item

You can of course use for example images instead of titles.

## Events

* `beforeRender` (items): Called right before first main render method is called
* `afterRender` (items): Called right after first main render method is called
* `registerType` (name, items): Called when there is new type added into select list
* `addType`: (name, items): Called after person select new type and it is added into result
* `removeType`: (name, items): Called after person remove type from result
* `addItem`: (type, value, items): Called after person add new value into some type
* `beforeRefresh`: (items): Called before summary refresh is called (eg. after adding new type)
* `afterRefresh`: (items): Called after summary refresh is called (eg. after adding new type)

Example:
```
items.on('addItem', function(type, value, items) {
	console.log("Item '" + value + "' was added into '" + type + "' group.");
});
```

## Example

![dialog](https://raw.github.com/sakren/node-items-dialog/master/example.png)

## Changelog

* 1.1.0
	+ Switched edit and remove buttons
	+ Adding new value is automatically called after new type is added
	+ More options for setup labels (+ doc)
	+ Items dialog is instance of EventEmitter
	+ Added events

* 1.0.2 - 1.0.3
	+ Bug in rendering summary
	+ Defaults from resume element

* 1.0.1
	+ Added missing example

* 1.0.0
	+ Initial version