`
import React, { Component, useState, useEffect } from 'react'
import { useIndexedDB } from 'react-indexed-db'
import moment from 'moment'
import * as _ from 'lodash'
import { Avatar, Collapse, Container, Divider, Icon, List, ListItem, ListItemAvatar, ListItemText, ListSubheader, Typography } from '@material-ui/core';
`

rugMeasurement = [
  (temp) -> -1 # unused
  (temp) -> -13.3 * temp + 133 # robust
  (temp) -> -20.5 * temp + 247 # empfindlich
  (temp) -> -17.6 * temp + 262 # Frostbeule
]
tempMeasurement = [
  (filling) -> 0 # unused
  (filling) ->  (filling - 133) / -13.3 # robust
  (filling) ->  (filling - 247) / -20.5 # empfindlich
  (filling) ->  (filling - 262) / -17.6 # Frostbeule
]

rainLimit = [0, 12, 15, 15]

getPerfectRug = (sensibility, rugs, day) =>
  fillingAvg = rugMeasurement[sensibility]((day.minTemp + day.maxTemp) / 2)
  
  # Regengrenze beachten
  if fillingAvg < 0 && day.minTemp <= rainLimit[sensibility] && (day.weather?[0]?.main == "Snow" || day.weather?[0]?.main == "Rain") 
    _.minBy rugs, 'filling'
  else if fillingAvg < 0
    { color: "#fafafa", fontColor: "darkgrey", brand: "Keine Decke" }
  else
    _.reduce rugs, (prev, curr) -> 
      if (Math.abs(curr.filling - fillingAvg) < Math.abs(prev.filling - fillingAvg)) then curr else prev
    , rugs[0]


DeckenDetails = (props) =>
  perfectTemp = tempMeasurement[props.sensibility](props.rug.filling)
  diffNight = Math.round perfectTemp - props.day.minTemp
  diffDay = Math.round perfectTemp - props.day.maxTemp
  text1 = <small>{"#{props.rug.brand} (#{props.rug.filling} g)"}</small>
  text2 = <small>
      {"Nachts #{Math.abs diffNight}°C zu #{(diffNight > 0 && "kalt") || "warm"}, 
      tagsüber #{Math.abs diffDay}°C zu #{(diffDay > 0 && "kalt") || "warm"}"}
    </small>

  <ListItem>
    <ListItemText id={props.rug.id} primary={text1} secondary={text2} style={{ margin: 0 }} />
  </ListItem>



WetterDetails = (props) =>
  <>
    <span key={'WetterDetails1' + props.day.dt} style={{ display: 'block' }}>
      {moment(props.day.dt * 1000).format("L")}
    </span>
    <span key={'WetterDetails2' + props.day.dt} style={{ display: 'block' }}>
      min. {props.day.minTemp}°C / max. {props.day.maxTemp}°C
    </span>
  </>


Days = (props) ->
  { getAll } = useIndexedDB('Decke')
  getAllRugs = getAll
  { getAll } = useIndexedDB('Pferd')
  getAllHorses = getAll
  [rugs, setRugs] = useState()
  [horses, setHorses] = useState()
  [open, setOpen] = useState(0)
 
  useEffect => 
    getAllRugs()
      .then (rugsFromDB) => setRugs(_.sortBy(rugsFromDB, 'filling')) if rugs?.length != rugsFromDB?.length
    getAllHorses()
      .then (horsesFromDB) => setHorses(_.sortBy(horsesFromDB, 'name')) if horses?.length != horsesFromDB?.length
 
  if rugs? && rugs?.length > 0 && horses? && horses?.length > 0
    if props.weatherResponse == "load"
      <Typography variant="body1">Wetter wird geladen...</Typography>
    else if props.weatherResponse? && props.weatherResponse?.daily?.length > 0
        <List dense disablePadding>
          {
            horses.map (horse) -> 
              <React.Fragment key={horse.name}>
                <ListSubheader style={{ backgroundColor: "#fafafa", paddingBottom: "10px" }}>
                  <Typography variant="subtitle1" gutterBottom>{horse.name}</Typography>
                </ListSubheader>
                {
                  _.sortBy(props.weatherResponse?.daily, 'dt').map (day) => 
                    day.minTemp = Math.round day.feels_like?.morn
                    day.maxTemp = Math.round day.feels_like?.day
                    perfectRug = getPerfectRug(horse.sensibility, rugs, day)
                    <React.Fragment key={day.dt}>
                      <ListItem button onClick={-> setOpen(if open == day.dt then 0 else day.dt)}>   
                        <ListItemAvatar>
                          <Avatar style={{ backgroundColor: perfectRug.color, color: perfectRug.fontColor }}>{moment(day.dt * 1000).format("dd")}</Avatar>
                        </ListItemAvatar>
                        <ListItemText id={day.dt} primary={perfectRug.brand} secondary={<WetterDetails day={day} />} />
                        {<Icon className="fas fa-cloud-showers-heavy" style={{ fontSize: 18, marginRight: 20, width: 20 }} /> if day.weather?[0]?.main == "Rain"}
                        {<Icon className="fas fa-snowflake" style={{ fontSize: 18, marginRight: 20, width: 20 }} /> if day.weather?[0]?.main == "Snow"}
                        <Icon className="fas fa-chevron-#{if open == day.dt then 'up' else 'down'}" style={{ fontSize: 15 }} /> 
                      </ListItem>
                      <Collapse in={open == day.dt} timeout="auto">
                        {
                          rugs.map (rug) -> 
                            <DeckenDetails key={"DeckenDetails" + rug.id} rug={rug} day={day} sensibility={horse.sensibility} />
                        }
                      </Collapse>
                      <Divider />
                    </React.Fragment>
                }
                <ListItem style={{height: "100px" }} />
              </React.Fragment>
          }
        </List>
    else
      <Typography variant="body1">Das Wetter konnte nicht abgefragt werden.</Typography>
  else
    [
      <Typography key="Typography1" variant="h5" component="h5" gutterBottom>Finde heraus, welche Decke dein Pferd heute braucht!</Typography>
      <Typography key="Typography2" variant="body1">Wähle eines der Symbole unten.</Typography>
      <Typography key="Typography3" variant="body1">Du musst mindestens ein Pferd und eine Decke anlegen, um eine Empfehlung zu bekommen.</Typography>
    ]

class Decken extends Component
  constructor: ->
    super()
    @state =
      showForm: false
      filling: 100
      brand: ""
      color: "red"

  render: ->
    <Container component="div" className="content" maxWidth="sm">
      <Typography variant="h2" component="h2" className="heading" gutterBottom>
        {'Empfehlung'}
      </Typography>

      <Days weatherResponse={@props.weatherResponse} />
    </Container>

export default Decken