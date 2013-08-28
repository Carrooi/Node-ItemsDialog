Dialog = require 'modal-dialog'
try $ = require '$' catch err then $ = window.jQuery

class Items


	types: null

	initialized: false

	dialog: null

	defaults: null


	select: null

	resultElement: null

	summaryElement: null


	constructor: ->
		@types = {}
		@defaults = {}


	prepare: ->
		header = $('<div>',
			html: $('<span>Items</span>')
		)
		@select = $('<select>',
			html: $('<option value="">Add new type</option>'),
			change: @onSelectChange
		)
		for name of @types
			@addTypeToSelection(name)

		@select.appendTo(header)

		@dialog = new Dialog
		@dialog.header = header
		@dialog.content = $('<div class="container"></div>')
		@dialog.addButton( 'OK', =>
			@dialog.hide()
		)

		for name, items of @defaults
			if items.length > 0
				@addType(name)
				for item in items
					@addValue(name, item)

		@initialized = true


	open: ->
		if !@initialized
			@prepare()

		@dialog.show()


	close: ->
		@dialog.hide()


	addTypeToSelection: (name) ->
		$('<option>',
			value: name
			html: @types[name]
		).appendTo(@select)


	onSelectChange: =>
		selected = @select.find(':selected')
		@addType(selected.attr('value'))


	addType: (name) ->
		title = $('<h3>',
			html: @types[name] + ' '
		)
		$('<a>',
			href: '#'
			html: 'Add'
			click: (e) =>
				e.preventDefault()
				name = $(e.target).closest('div.type').attr('data-name')
				value = prompt('Please enter new item for ' + @types[name])
				if value != '' && value != null
					@addValue(name, value)
		).appendTo(title)
		title.append(' ')
		$('<a>',
			href: '#'
			html: 'Remove'
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


	removeType: (name) ->
		@dialog.content.find('div.type[data-name="' + name + '"]').remove()
		@addTypeToSelection(name)
		if @select.is(':hidden') then @select.show()
		@refreshOutputs()


	addValue: (type, value) ->
		list = @dialog.content.find('div.type[data-name="' + type + '"] ul')
		item = $('<li>',
			html: $('<span>' + value + '</span>')
		)
		item.append(' ')
		$('<a>',
			href: '#'
			html: 'Remove'
			click: (e) =>
				e.preventDefault()
				item.remove()
				@refreshOutputs()
		).appendTo(item)
		item.append(' ')
		$('<a>',
			href: '#'
			html: 'Edit'
			click: (e) =>
				e.preventDefault()
				value = prompt('Please enter new item for ' + @types[type], value)
				if value != '' && value != null
					item.find('span').html(value)
					@refreshOutputs()
		).appendTo(item)

		item.appendTo(list)

		@refreshOutputs()


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
			throw new Error 'Resule: invalid element'

		@resultElement = el


	setSummaryElement: (el) ->
		el = $(el)
		if el.get(0).nodeName.toLowerCase() != 'div'
			throw new Error 'Summary: invalid element'

		el.append($('<ul>'))

		@summaryElement = el


	refreshOutputs: ->
		values = @getValues()

		if @resultElement != null
			@resultElement.val(JSON.stringify(values))

		if @summaryElement != null
			@summaryElement.find('ul').html('')
			for name, items of values
				type = $('<li>',
					html: @types[name]
				)
				if items.length > 0
					ul = $('<ul>')
					for item in items
						$('<li>' + item + '</li>').appendTo(ul)
					ul.appendTo(type)

				type.appendTo(@summaryElement.find('ul'))


module.exports = Items