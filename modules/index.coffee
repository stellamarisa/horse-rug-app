`
import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import { DBConfig } from './DBConfig'
import { initDB } from 'react-indexed-db'
import moment from 'moment'
import 'moment/locale/de'

import '@fortawesome/fontawesome-free/js/all.min.js'
import '@fortawesome/fontawesome-free/css/all.min.css'

import Pferde from './Pferde'
import Decken from './Decken'
import Wetter from './Wetter'
import Home from './Home'

import { BottomNavigation, BottomNavigationAction, CssBaseline, Icon, ThemeProvider } from '@material-ui/core'
import { createTheme } from '@material-ui/core/styles'
`

initDB(DBConfig)

theme = createTheme({
  palette: {
    primary: {
      light: '#bc477b'
      main: '#880e4f'
      dark: '#560027'
      contrastText: '#fff'
    }
    secondary: {
      light: '#ff5c8d'
      main: '#d81b60'
      dark: '#a00037'
      contrastText: '#fff'
    }
  }
})

class App extends Component
  constructor: ->
    super()
    @_isMounted = false
    @state =
      page: 0
      weatherResponse: "load"

  componentDidMount: ->
    @_isMounted = true
    moment.locale('de')
    navigator.geolocation.getCurrentPosition((position) =>
      fetch("https://api.openweathermap.org/data/2.5/onecall?lat=#{position.coords.latitude}&lon=#{position.coords.longitude}&units=metric&lang=de&exclude=current,minutely,hourly&appid=#{process.env.WEATHER_API_KEY}")
        .then (response) => response.json()
        .then (data) => @setState weatherResponse: data if @_isMounted
        .catch (e) => @setState weatherResponse: null if @_isMounted
    )

  componentWillUnmount: ->
    @_isMounted = false

  render: ->
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <div className="main">
        {
          if @state.page == 1
            <Pferde />
          else if @state.page == 2
            <Decken />
          else if @state.page == 3
            <Wetter weatherResponse={@state.weatherResponse} />
          else
            <Home weatherResponse={@state.weatherResponse} />
        }
      </div>
      <BottomNavigation value={@state.page} onChange={(event, val) => @setState page: val} showLabels className="footer">
        <BottomNavigationAction className="navButton" label="Start" icon={<Icon className="fas fa-home" style={{ fontSize: 35, minWidth: 50, marginBottom: 10 }} />} />
        <BottomNavigationAction className="navButton" label="Pferde" icon={<Icon className="fas fa-horse-head" style={{ fontSize: 35, minWidth: 50, marginBottom: 10 }} />} />
        <BottomNavigationAction className="navButton" label="Decken" icon={<Icon className="fas fa-shopping-bag" style={{ fontSize: 35, minWidth: 50, marginBottom: 10 }} />} />
        <BottomNavigationAction className="navButton" label="Wetter" icon={<Icon className="fas fa-cloud-sun-rain" style={{ fontSize: 35, minWidth: 50, marginBottom: 10 }} />} />
      </BottomNavigation>
    </ThemeProvider>

ReactDOM.render <App />, document.getElementById 'root'