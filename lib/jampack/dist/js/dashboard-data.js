/*Dashboard Init*/
"use strict"; 
/*DataTable Init*/
if ($("#datable_1").length > 0) {
	/*Checkbox Add*/
	var tdCnt=0;
	$('table tr').each(function(){
		$('<span class="form-check mb-0"><input type="checkbox" class="form-check-input check-select" id="chk_sel_'+tdCnt+'"><label class="form-check-label" for="chk_sel_'+tdCnt+'"></label></span>').appendTo($(this).find("td:first-child"));
		tdCnt++;
	});
	var targetDt = $('#datable_1').DataTable({
		"dom": '<"row"<"col-7 mb-3"<"contact-toolbar-left">><"col-5 mb-3"<"contact-toolbar-right"f>>><"row"<"col-sm-12"t>><"row"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>',
		"ordering": true,
		"columnDefs": [ {
			"searchable": false,
			"orderable": false,
			"targets": [0,5]
		} ],
		"order": [1, 'asc' ],
		language: { search: "",
			searchPlaceholder: "Search",
			"info": "_START_ - _END_ of _TOTAL_",
			sLengthMenu: "View  _MENU_",
			paginate: {
			  next: '<i class="ri-arrow-right-s-line"></i>', // or '→'
			  previous: '<i class="ri-arrow-left-s-line"></i>' // or '←' 
			}
		},
		"drawCallback": function () {
			$('.dataTables_paginate > .pagination').addClass('custom-pagination pagination-simple pagination-sm');
		}
	});
	$(document).on( 'click', '.del-button', function () {
		targetDt.rows('.selected').remove().draw( false );
		return false;
	});
	$("div.contact-toolbar-left").html('<div class="d-xxl-flex d-none align-items-center"><div class="btn-group btn-group-sm" role="group" aria-label="Basic outlined example"><button type="button" class="btn btn-outline-light active">View all</button><button type="button" class="btn btn-outline-light">Monitored</button><button type="button" class="btn btn-outline-light">Unmonitored</button></div>');
	$("div.contact-toolbar-right").addClass('d-flex justify-content-end').append('	<button class="btn btn-sm btn-outline-light ms-3"><span><span class="icon"><i class="bi bi-filter"></i></span><span class="btn-text">Filters</span></span></button>');
	$("#datable_1").parent().addClass('table-responsive');
	
	/*Select all using checkbox*/
	var  DT1 = $('#datable_1').DataTable();
	$(".check-select-all").on( "click", function(e) {
		$('.check-select').attr('checked', true);
		if ($(this).is( ":checked" )) {
			DT1.rows().select();    
			$('.check-select').prop('checked', true);			
		} else {
			DT1.rows().deselect(); 
			$('.check-select').prop('checked', false);
		}
	});
	$(".check-select").on( "click", function(e) {
		if ($(this).is( ":checked" )) {
			$(this).closest('tr').addClass('selected');        
		} else {
			$(this).closest('tr').removeClass('selected');
			$('.check-select-all').prop('checked', false);
		}
	});
}

/*Apex Column Chart*/
window.Apex = {
	chart: {
		foreColor: "#646A71",
		fontFamily: 'DM Sans',
		toolbar: {
			tools: {
				download: '<svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>',
				selection: '<img src="/static/icons/reset.png" width="20">',
				zoom: '<svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line><line x1="11" y1="8" x2="11" y2="14"></line><line x1="8" y1="11" x2="14" y2="11"></line></svg>',
				zoomin: '<svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>',
				zoomout: '<svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="8" y1="12" x2="16" y2="12"></line></svg>',
				pan: '<svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="5 9 2 12 5 15"></polyline><polyline points="9 5 12 2 15 5"></polyline><polyline points="15 19 12 22 9 19"></polyline><polyline points="19 9 22 12 19 15"></polyline><line x1="2" y1="12" x2="22" y2="12"></line><line x1="12" y1="2" x2="12" y2="22"></line></svg>',
				reset: '<svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>',
			}
		}
	},
	grid: {
		borderColor: '#F4F5F6',
	},
	xaxis: {
		labels: {
			style: {
				fontSize: '12px',
				fontFamily: 'inherit',
			},
		},
		axisBorder: {
			show: false,
		},
		title: {
			style: {
				fontSize: '12px',
				fontFamily: 'inherit',
			}
		}
	},
	yaxis: {
		labels: {
			style: {
				fontSize: '12px',
				fontFamily: 'inherit',
			},
		},
		title: {
			style: {
				fontSize: '12px',
				fontFamily: 'inherit',
			}
		},
	},
};
/*Stacked Column*/
var options1 = {
	series: [{
		name: 'PRODUCT A',
		data: [44, 55, 41, 67, 22, 43,44, 55, 41, 67, 22, 43]
	}, {
		name: 'PRODUCT B',
		data: [13, 23, 20, 8, 13, 27,13, 23, 20, 8, 13, 27]
	}, {
		name: 'PRODUCT C',
		data: [11, 17, 15, 15, 21, 14,11, 17, 15, 15, 21, 14]
	}],
	chart: {
		type: 'bar',
		height: 250,
		stacked: true,
		toolbar: {
			show: false
		},
		zoom: {
			enabled: false
		},
	},
	
	plotOptions: {
		bar: {
			horizontal: false,
			columnWidth: '35%',
			borderRadius: 5,
			
		},
	},
	xaxis: {
		type: 'datetime',
		categories: ['01/02/2021 GMT', '01/03/2021 GMT', '01/04/2021 GMT',
			'01/05/2021 GMT', '01/06/2021 GMT','01/07/2021 GMT', '01/08/2021 GMT', '01/09/2021 GMT', '01/10/2021 GMT',
			'01/11/2021 GMT', '01/12/2021 GMT','01/13/2021 GMT'
		],
	},
	legend: {
		show:false
	},
	colors: ['#007D88', '#25cba1', '#ebf3fe'],
	fill: {
		opacity: 1
	},
	dataLabels: {
		enabled: false,
	}
};
var chart1 = new ApexCharts(document.querySelector("#column_chart_2"), options1);
chart1.render();


/*Multiple Chart*/
var options2 = {
	series: [80, 75],
	stroke: {
		lineCap: 'round'
	},
	chart: {
		height: 255,
		type: 'radialBar',
	},
	plotOptions: {
		radialBar: {
			hollow: {
				margin: 0,
				size: "55%",
			},
			dataLabels: {
				showOn: "always",
				name: {
					show: false,
				},
				value: {
					fontSize: "1.75rem",
					show: true,
					fontWeight: '500'
				}	,
				total: {
					show: true,
					formatter: function () {
						return [('$2249')];
					}
				}
			  }
		}
	},
	colors: ['#007D88', '#25cba1'],
	labels: ['Subscriptions', 'Food'],
};

var chart2 = new ApexCharts(document.querySelector("#radial_chart_2"), options2);
chart2.render();
