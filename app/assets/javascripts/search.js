$(document).ready(function(){
	var $vartypeahead = $('#search_search');
	var engine = new Bloodhound({
	  name: 'users',
	  remote: {"url":'/search/autocomplete?query=%QUERY',
        filter: function (response) {
            // do whatever processing you need here
            return response;
        }},
	  datumTokenizer: function(d) { return d;},
	  queryTokenizer: function(d) { return d;}
	});
	engine.initialize();

	$vartypeahead.typeahead({
	          "minLength": 1,
	          "highlight": true
	        },
	        { name: 'users',
	          displayKey: function (engine) {
	              return engine.patreon;
	          },
	          "source": engine.ttAdapter(),
			  templates: {
			    empty: [
			      '<div class="empty-message">',
			      'No Patreon users found.',
			      '</div>'
			    ].join('\n'),
			    suggestion: Handlebars.compile('<p><strong>{{name}}</strong> – {{patreon}}</p>')
			  }
	          });
});