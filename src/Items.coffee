Dialog = require 'modal-dialog'
EventEmitter = require('events').EventEmitter
try $ = require '$' catch err then $ = window.jQuery

class Items extends EventEmitter


	@labels =
		title: 'Items'
		addTypeHint: 'Add new type'
		removeType: 'Remove'
		okButton: 'OK'
		writeItem: 'Please enter new item for %s'
		removeItem: 'Remove'
		editItem: 'Edit'
		addItem: 'Add'
		help: 'There you can add new types. Just select it in menu above.'


	types: null

	initialized: false

	dialog: null

	defaults: null

	labels: null


	select: null

	resultElement: null

	summaryElement: null


	constructor: ->
		@types = {}
		@defaults = {}
		@labels = {}


	prepare: ->
		if !@initialized
			@emit 'beforeRender', @

			@prepareLabels()

			header = $('<div>',
				html: $('<span>' + @labels.title + '</span>')
			)
			@select = $('<select>',
				html: $('<option value="">' + @labels.addTypeHint + '</option>'),
				change: @onSelectChange
			)
			for name of @types
				@addTypeToSelection(name)

			@select.appendTo(header)

			@dialog = new Dialog
			@dialog.header = header
			@dialog.content = $('<div class="container"><div class="help">' + @labels.help + '</div></div>')
			@dialog.addButton( @labels.okButton, =>
				@dialog.hide()
			)

			for name, items of @defaults
				if items.length > 0
					@addType(name)
					for item in items
						@addValue(name, item)

			@initialized = true

			@emit 'afterRender', @


	prepareLabels: ->
		if typeof @labels.title == 'undefined' then @labels.title = Items.labels.title
		if typeof @labels.addTypeHint == 'undefined' then @labels.addTypeHint = Items.labels.addTypeHint
		if typeof @labels.removeType == 'undefined' then @labels.removeType = Items.labels.removeType
		if typeof @labels.okButton == 'undefined' then @labels.okButton = Items.labels.okButton
		if typeof @labels.writeItem == 'undefined' then @labels.writeItem = Items.labels.writeItem
		if typeof @labels.removeItem == 'undefined' then @labels.removeItem = Items.labels.removeItem
		if typeof @labels.editItem == 'undefined' then @labels.editItem = Items.labels.editItem
		if typeof @labels.addItem == 'undefined' then @labels.addItem = Items.labels.addItem
		if typeof @labels.help == 'undefined' then @labels.help = Items.labels.help


	open: ->
		@prepare()
		@dialog.show()


	close: ->
		@dialog.hide()


	addTypeToSelection: (name) ->
		@emit 'registerType', name, @

		$('<option>',
			value: name
			html: @types[name]
		).appendTo(@select)


	onSelectChange: =>
		selected = @select.find(':selected')
		@addType(selected.attr('value'), true)


	addType: (name, autoAddValue = false) ->
		title = $('<h3>',
			html: @types[name] + ' '
		)
		addButton = $('<a>',
			href: '#'
			html: @labels.addItem
			click: (e) =>
				e.preventDefault()
				name = $(e.target).closest('div.type').attr('data-name')
				msg = @labels.writeItem.replace(/\%s/g, @types[name])
				value = prompt(msg)
				if value != '' && value != null
					@addValue(name, value)
		).appendTo(title)
		title.append(' ')
		$('<a>',
			href: '#'
			html: @labels.removeType
			click: (e) =>
				e.preventDefault()
				@removeType($(e.target).closest('div.type').attr('data-name'))
		).appendTo(title)

		box = $('<div>',
			'class': 'type'
			html: title
			'data-name': name
		)
		$('<ul></ul>').appendTo(box)

		box.appendTo(@dialog.content)
		@select.find('option[value=""]').prop('selected', true)
		@select.find('option[value="' + name + '"]').remove()

		@refreshOutputs()

		if @select.find('option').length == 1
			@select.hide()

		@emit 'addType', name, @

		if autoAddValue then addButton.click()


	removeType: (name) ->
		@dialog.content.find('div.type[data-name="' + name + '"]').remove()
		@addTypeToSelection(name)
		if @select.is(':hidden') then @select.show()
		@refreshOutputs()

		@emit 'removeType', name, @


	addValue: (type, value) ->
		list = @dialog.content.find('div.type[data-name="' + type + '"] ul')
		item = $('<li>',
			html: $('<span>' + value + '</span>')
		)
		item.append(' ')
		$('<a>',
			href: '#'
			html: @labels.editItem
			click: (e) =>
				e.preventDefault()
				msg = @labels.writeItem.replace(/\%s/g, @types[type])
				value = prompt(msg, value)
				if value != '' && value != null
					item.find('span').html(value)
					@refreshOutputs()
		).appendTo(item)
		item.append(' ')
		$('<a>',
			href: '#'
			html: @labels.removeItem
			click: (e) =>
				e.preventDefault()
				item.remove()
				@refreshOutputs()
		).appendTo(item)

		item.appendTo(list)

		@refreshOutputs()

		@emit 'addItem', type, value, @


	getValues: ->
		result = {}

		@dialog.content.find('div.type[data-name]').each( (i, el) ->
			el = $(el)
			name = el.attr('data-name')

			if el.find('ul li').length > 0
				result[name] = []

				el.find('ul li').each( (i, li) ->
					li = $(li)
					result[name].push(li.find('span').html())
				)
		)

		return result


	setResultElement: (el) ->
		el = $(el)
		if el.get(0).nodeName.toLowerCase() != 'input' || el.attr('type') != 'text'
			throw new Error 'Result: invalid element'

		if el.val() != ''
			@defaults = JSON.parse(el.val())

		@resultElement = el


	setSummaryElement: (el) ->
		el = $(el)
		if el.get(0).nodeName.toLowerCase() != 'div'
			throw new Error 'Summary: invalid element'

		el.append($('<ul>'))

		@summaryElement = el


	refreshOutputs: ->
		@emit 'beforeRefresh', @

		values = @getValues()

		if @resultElement != null
			@resultElement.val(JSON.stringify(values))

		if @summaryElement != null
			list = @summaryElement.children('ul')
			list.html('')
			for name, items of values
				type = $('<li>',
					html: @types[name]
				)
				if items.length > 0
					ul = $('<ul>')
					for item in items
						$('<li>' + item + '</li>').appendTo(ul)
					ul.appendTo(type)

				type.appendTo(list)

		@emit 'afterRefresh', @


module.exports = Items