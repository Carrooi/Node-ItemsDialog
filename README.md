# Items dialog

Modal dialog for writing items in groups (eg. contacts).
Using [modal-dialog](https://npmjs.org/package/modal-dialog) package and is dependent on jquery.

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

```
items.setResultElement($('#myInputInForm'));
```

## Showing summary of items

This feature is like the previous one, except one thing. You are connecting div element not text input and data are rendered
into this element.

```
items.setSummaryElement($('mySummaryElement'));
```

## Example



## Changelog

* 1.0.0
	+ Initial version