`
import React, { Component } from 'react'
import moment from 'moment'
import * as _ from 'lodash'
import { Container, Divider, Icon, List, ListItem, ListItemAvatar, ListItemText, Typography } from '@material-ui/core';
`

icons = {
  1: "sun", 
  2: "cloud-sun", 
  3: "cloud", 
  4: "cloud", 
  9: "cloud-rain", 
  10: "cloud-showers-heavy", 
  11: "bolt", 
  13: "snowflake", 
  50: "smog"
}

class Wetter extends Component
  constructor: ->
    super()
    @_isMounted = false
    @state =
      city: ""

  componentDidMount: ->
    @_isMounted = true
    moment.locale('de')
    # fetch("https://maps.googleapis.com/maps/api/geocode/json?latlng=#{@props.weatherResponse?.lat},#{@props.weatherResponse?.lon}&key=#{process.env.GEOLOCATION_KEY}")
    #   .then (response) => response.json()
    #   .then (data) => console.log data #@setState city: data if @_isMounted
    #   .catch (e) => @setState city: "" if @_isMounted

  componentWillUnmount: ->
    @_isMounted = false

  render: ->
    <Container component="div" className="content" maxWidth="sm">
      <Typography variant="h2" component="h1" className="heading" gutterBottom> {'Wetter'} </Typography>
      <Typography variant="h5" component="h2"> {this.state.city} </Typography>
      {
        if @props.weatherResponse == "load"
          <Typography variant="body1">Wetter wird geladen...</Typography>
        else if @props.weatherResponse? && @props.weatherResponse?.daily?.length > 0
          <List dense>
            {
              _.sortBy(@props.weatherResponse?.daily, 'dt').map (day) => 
                subText = [
                  <span key={'subText1' + day.dt} style={{ display: 'block' }}>
                    min. {Math.round day.feels_like?.morn}°C / max. {Math.round day.feels_like?.day}°C
                  </span>
                  <span key={'subText2' + day.dt} style={{ display: 'block' }}>
                    {day.weather?[0]?.description}
                  </span>
                ]
                [
                  <ListItem key={'day' + day.dt}>   
                    <ListItemAvatar>
                      <Icon className="fas fa-#{icons[parseInt day.weather?[0].icon]}" style={{ fontSize: 20, width: 26, textAlign: 'center' }} />
                    </ListItemAvatar>
                    <ListItemText id={day.dt} primary={moment(day.dt * 1000).format("dd, LL")} secondary={subText} />
                  </ListItem>
                  <Divider key={'dayDiv' + day.id} />
                ]
            }
          </List>
        else
          <Typography variant="body1">Das Wetter konnte nicht abgefragt werden.</Typography>
      }
    </Container>

export default Wetter