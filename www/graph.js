var Data = {
  type: 'scatter',
  x: ['Jan-19','Feb-19','Mar-19','Apr-19','May-19','Jun-19','Jul-19','Aug-19','Sep-19','Oct-19','Nov-19','Dec-19','Jan-20','Feb-20','Mar-20','Apr-20','May-20','Jun-20','Jul-20','Aug-20','Sep-20','Oct-20','Nov-20','Dec-20','Jan-21','Feb-21','Mar-21','Apr-21','May-21'],
  y: [95,96,93,94,95,95,94.5,91.5,95,null,94,null,96,null,92.5,87.5,null,null,null,null,null,85,null,null,null,null,null,87,null],
  mode: 'lines+markers',
  connectgaps: true,
  name: 'Data',
  showlegend: true,
  hoverinfo: 'all',
  line: {
    color: 'blue',
    width: 2
  },
  marker: {
    color: 'blue',
    size: 8,
    symbol: 'circle'
  }
}

var Viol = {
  type: 'scatter',
  x: ['Feb-19','Jan-20','Apr-20','Oct-20','Apr-21'],
  y: [96,96,87.5,85,87],
  mode: 'markers',
  name: 'Violation',
  showlegend: true,
  marker: {
    color: 'rgb(255,65,54)',
    line: {width: 3},
    opacity: 0.5,
    size: 12,
    symbol: 'circle-open'
  }
}

var CL = {
  type: 'scatter',
  x: ['Jan-19','Apr-21',null,'Jan-19','Apr-21'],
  y: [91,91,null,95,95],
  mode: 'lines',
  name: 'LCL/UCL',
  showlegend: true,
  line: {
    color: 'red',
    width: 2,
    dash: 'dash'
  }
}

var Centre = {
  type: 'scatter',
  x: ['Jan-19', 'Apr-21'],
  y: [93, 93],
  mode: 'lines',
  name: 'Centre',
  showlegend: true,
  line: {
    color: 'grey',
    width: 2
  }
}

var data = [Data,Viol,CL,Centre]

var layout = {
  title: 'XBar Chart of FFT',
  xaxis: {
    zeroline: false,
    title: 'Month'
  },
  yaxis: {
    range: [83,97],
    zeroline: false,
    title: '% FFT Score'
  },
  annotations: [
    {
      x: 'May-21',
      y: 95,
      xref: 'x',
      yref: 'y',
      text: '95',
      showarrow: false,
      arrowhead: 0,
      ax: 0,
      ay: 0
    },
    {
      x: 'May-21',
      y: 91,
      xref: 'x',
      yref: 'y',
      text: '91',
      showarrow: false,
      arrowhead: 0,
      ax: 0,
      ay: 0
    },
    {
      x: 'May-21',
      y: 93,
      xref: 'x',
      yref: 'y',
      text: '93',
      showarrow: false,
      arrowhead: 0,
      ax: 0,
      ay: 0
    }
  ]
}

// Display using Plotly
Plotly.newPlot("myPlot", data, layout);