AUI.add(
	'liferay-ddm-form-renderer-field',
	function(A) {
		var AArray = A.Array;
		var AObject = A.Object;
		var Lang = A.Lang;
		var Renderer = Liferay.DDM.Renderer;

		var FieldTypes = Renderer.FieldTypes;
		var Util = Renderer.Util;

		var TPL_DIV = '<div></div>';

		var TPL_FORM_FIELD_CONTAINER = '<div class="lfr-ddm-form-field-container"></div>';

		var Field = A.Component.create(
			{
				ATTRS: {
					container: {
						setter: A.one,
						valueFn: '_valueContainer'
					},

					fieldNamespace: {
						value: ''
					},

					indexType: {
						value: 'keyword'
					},

					instanceId: {
						valueFn: '_valueInstanceId'
					},

					label: {
						getter: '_getLabel',
						value: ''
					},

					locale: {
						value: themeDisplay.getLanguageId()
					},

					localizable: {
						setter: A.DataType.Boolean.parse,
						value: true
					},

					name: {
						value: ''
					},

					parent: {
						setter: '_setParent'
					},

					portletNamespace: {
						value: ''
					},

					predefinedValue: {
						valueFn: '_getDefaultValue'
					},

					readOnly: {
						value: false
					},

					required: {
						setter: A.DataType.Boolean.parse,
						value: false
					},

					showLabel: {
						setter: A.DataType.Boolean.parse,
						value: true
					},

					tip: {
						value: {}
					},

					type: {
						value: ''
					},

					value: {
						valueFn: '_getDefaultValue'
					}
				},

				AUGMENTS: [
					Renderer.FieldEventsSupport,
					Renderer.FieldFeedbackSupport,
					Renderer.FieldRepetitionSupport,
					Renderer.FieldValidationSupport,
					Renderer.FieldVisibilitySupport,
					Renderer.NestedFieldsSupport
				],

				EXTENDS: A.Base,

				NAME: 'liferay-ddm-form-renderer-field',

				prototype: {
					initializer: function() {
						var instance = this;

						instance._eventHandlers = [
							instance.after('localizableChange', instance._afterLocalizableChange),
							instance.after('valueChange', instance._afterValueChange)
						];
					},

					destructor: function() {
						var instance = this;

						var container = instance.get('container');

						if (container) {
							container.remove(true);
						}

						var parent = instance.get('parent');

						if (parent) {
							parent.removeChild(instance);
						}

						(new A.EventHandle(instance._eventHandlers)).detach();
					},

					fetchContainer: function() {
						var instance = this;

						var instanceId = instance.get('instanceId');

						var container = instance._getContainerByInstanceId(instanceId);

						if (!container) {
							var name = instance.get('name');

							var repeatedIndex = instance.get('repeatedIndex');

							container = instance._getContainerByNameAndIndex(name, repeatedIndex);
						}

						return container;
					},

					focus: function() {
						var instance = this;

						instance.get('container').scrollIntoView();

						instance.getInputNode().focus();
					},

					getChildElementsHTML: function() {
						var instance = this;

						return instance.get('fields').map(
							function(field) {
								var fragment = A.Node.create(TPL_DIV);

								var container = field._createContainer();

								container.html(field.getTemplate());

								container.appendTo(fragment);

								return fragment.html();
							}
						).join('');
					},

					getInputNode: function() {
						var instance = this;

						return instance.get('container').one(instance.getInputSelector());
					},

					getInputSelector: function() {
						var instance = this;

						var qualifiedName = instance.getQualifiedName().replace(/\$/ig, '\\$');

						return '[name=' + qualifiedName + ']';
					},

					getLabel: function() {
						var instance = this;

						var label = instance.get('label');
						var locale = instance.get('locale');

						if (Lang.isObject(label) && locale in label) {
							label = label[locale];
						}

						return label || instance.get('name');
					},

					getLabelNode: function() {
						var instance = this;

						return instance.get('container').one('label');
					},

					getQualifiedName: function() {
						var instance = this;

						return [
							instance.get('portletNamespace'),
							'ddm$$',
							instance.get('name'),
							'$',
							instance.get('instanceId'),
							'$',
							instance.get('repeatedIndex'),
							'$$',
							instance.get('locale')
						].join('');
					},

					getSerializedValue: function() {
						var instance = this;

						var serializedValue;

						if (instance.get('localizable')) {
							serializedValue = {};

							serializedValue[instance.get('locale')] = instance.getValue();
						}
						else {
							serializedValue = instance.getValue();
						}

						return serializedValue;
					},

					getTemplate: function() {
						var instance = this;

						var renderer = instance.getTemplateRenderer();

						return renderer(instance.getTemplateContext());
					},

					getTemplateContext: function() {
						var instance = this;

						var context = {};

						var fieldType = FieldTypes.get(instance.get('type'));

						A.each(
							fieldType.get('settings').fields,
							function(item, index) {
								context[item.name] = instance.get(item.name);
							}
						);

						var value = instance.get('value');

						if (instance.get('localizable') && Lang.isObject(value)) {
							value = value[instance.get('locale')];
						}

						return A.merge(
							context,
							{
								childElementsHTML: instance.getChildElementsHTML(),
								label: instance.getLabel(),
								name: instance.getQualifiedName(),
								value: value || '',
								visible: instance.get('visible')
							}
						);
					},

					getTemplateRenderer: function() {
						var instance = this;

						var type = instance.get('type');

						var fieldType = FieldTypes.get(type);

						if (!fieldType) {
							throw new Error('Unknown field type "' + type + '".');
						}

						var templateNamespace = fieldType.get('templateNamespace');

						return AObject.getValue(window, templateNamespace.split('.'));
					},

					getValue: function() {
						var instance = this;

						var inputNode = instance.getInputNode();

						return Lang.String.unescapeHTML(inputNode.val());
					},

					render: function(target) {
						var instance = this;

						var container = instance.get('container');

						var parent = instance.get('parent');

						if (target && !parent) {
							container.appendTo(target);
						}

						container.html(instance.getTemplate());

						instance.eachField(
							function(field) {
								var container = field.fetchContainer();

								if (!container) {
									container = field._createContainer();
								}

								field.set('container', container);
							}
						);

						instance.fire('render');

						return instance;
					},

					setValue: function(value) {
						var instance = this;

						instance.getInputNode().val(value);
					},

					toJSON: function() {
						var instance = this;

						var fieldJSON = {
							instanceId: instance.get('instanceId'),
							name: instance.get('name'),
							value: instance.getSerializedValue()
						};

						var fields = instance.get('fields');

						if (fields.length > 0) {
							fieldJSON.nestedFieldValues = AArray.invoke(fields, 'toJSON');
						}

						return fieldJSON;
					},

					_afterLocalizableChange: function() {
						var instance = this;

						instance.set('value', instance._getDefaultValue());
					},

					_afterValueChange: function() {
						var instance = this;

						instance.render();
					},

					_createContainer: function() {
						var instance = this;

						var container = A.Node.create(TPL_FORM_FIELD_CONTAINER);

						container.html(instance.getTemplate());

						return container;
					},

					_getContainerByInstanceId: function(instanceId) {
						var instance = this;

						var container;

						var root = instance.getRoot();

						if (root) {
							container = root.filterNodes(
								function(qualifiedName) {
									var nodeInstanceId = Util.getInstanceIdFromQualifiedName(qualifiedName);

									return instanceId === nodeInstanceId;
								}
							).item(0);
						}

						return container;
					},

					_getContainerByNameAndIndex: function(name, repeatedIndex) {
						var instance = this;

						var container;

						var root = instance.getRoot();

						if (root) {
							container = instance.getRoot().filterNodes(
								function(qualifiedName) {
									var nodeFieldName = Util.getFieldNameFromQualifiedName(qualifiedName);

									return name === nodeFieldName;
								}
							).item(repeatedIndex);
						}

						return container;
					},

					_getDefaultValue: function() {
						var instance = this;

						var value = '';

						if (instance.get('localizable')) {
							value = {};

							value[instance.get('locale')] = '';
						}

						return value;
					},

					_setParent: function(val) {
						var instance = this;

						var fields = val.get('fields');

						var name = instance.get('name');

						if (fields && !val.getField(name)) {
							fields.push(instance);
						}

						instance.addTarget(val);
					},

					_valueContainer: function() {
						var instance = this;

						var container = instance.fetchContainer();

						if (!container) {
							container = instance._createContainer();
						}

						return container;
					},

					_valueInstanceId: function() {
						var instance = this;

						return Util.generateInstanceId(8);
					}
				}
			}
		);

		Liferay.namespace('DDM.Renderer').Field = Field;
	},
	'',
	{
		requires: ['aui-datatype', 'aui-node', 'liferay-ddm-form-renderer', 'liferay-ddm-form-renderer-field-events', 'liferay-ddm-form-renderer-field-feedback', 'liferay-ddm-form-renderer-field-repetition', 'liferay-ddm-form-renderer-field-validation', 'liferay-ddm-form-renderer-field-visibility', 'liferay-ddm-form-renderer-nested-fields', 'liferay-ddm-form-renderer-types', 'liferay-ddm-form-renderer-util']
	}
);