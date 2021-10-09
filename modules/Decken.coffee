`
import React, { Component, useState, useEffect } from 'react'
import { useIndexedDB } from 'react-indexed-db'
import * as _ from 'lodash'
import { Avatar, Button, Container, Dialog, DialogActions, Divider, Fab, FormControl, Grid, Icon, InputLabel, List, ListItem, ListItemAvatar, ListItemText, MenuItem, Radio, Select, TextField, Typography } from '@material-ui/core';
import SwipeToDelete from 'react-swipe-to-delete-component';
`

AddNewButton = (props) ->
  { add } = useIndexedDB('Decke')
 
  handleClick = () =>
    if props.brand !=""
      add { brand: props.brand, filling: props.filling, color: props.color }
        .then(
          (event) => props.onClose()
          (error) => console.error error
        )

  <Button onClick={handleClick} color="primary"> {'Speichern'} </Button>


RugList = (props) ->
  { getAll, deleteRecord } = useIndexedDB('Decke');
  [rugs, setRugs] = useState();
 
  useEffect => 
    getAll()
      .then (rugsFromDB) => setRugs(rugsFromDB) if rugs?.length != rugsFromDB?.length

  deleteRug = ({ item: rug }) =>
    deleteRecord(rug.id).then => setRugs(_.reject(rugs, { id: rug.id }))

  colors = {
    deeppink: ['deeppink', 'darkred']
    red: ['red', 'maroon']
    orange: ['orange', 'orangered']
    yellow: ['yellow', 'goldenrod']
    limegreen: ['greenyellow', 'limegreen']
    green: ['seagreen', 'darkgreen']
    teal: ['lightseagreen', 'darkslategrey']
    cyan: ['cyan', 'darkcyan']
    blue: ['slateblue', 'black']
    purple: ['mediumorchid', 'darkmagenta']
    maroon: ['sienna', 'maroon']
    black: ['darkslategrey', 'black']
    grey: ['grey', 'darkslategrey']
  }
 
  if rugs? && rugs?.length > 0
    <List dense>
      {
        _.sortBy(rugs, 'filling').map (rug) => 
          [
            <SwipeToDelete key={rug.id} item={rug} onDelete={deleteRug} deleteSwipe={0.3}>
              <ListItem key={'rug' + rug.id}>   
                <ListItemAvatar>
                  <Avatar style={{ background: "radial-gradient(#{colors[rug.color]?[0]}, #{colors[rug.color]?[1]})" }}> {''} </Avatar>
                </ListItemAvatar>
                <ListItemText id={rug.brand} primary={rug.brand} secondary={rug.filling + 'g'} />
              </ListItem>
              <Divider key={'rugDiv' + rug.id} />
            </SwipeToDelete>
          ]
      }
    </List>
  else
    <Typography variant="body1">Noch keine Decke angelegt.</Typography>


class Decken extends Component
  constructor: ->
    super()
    @state =
      showForm: false
      filling: 0
      brand: ""
      color: "red"

  render: ->
    colors = ['deeppink', 'red', 'orange', 'yellow', 'limegreen', 'green', 'teal', 'cyan', 'blue', 'purple', 'maroon', 'black', 'grey']
            
    <Container component="div" className="content" maxWidth="sm">
      <Typography variant="h2" component="h2" className="heading" gutterBottom>
        {'Decken'}
        <Fab color="primary" size="small" aria-label="add" onClick={=> @setState showForm: true} style={{ marginLeft: '30px' }}>
          <Icon className="fas fa-plus"/>
        </Fab>
      </Typography>

      <Dialog open={@state.showForm} onClose={=> @setState showForm: false}>
        <InputLabel id="brand-label" margin="dense" shrink>Hersteller / Modell / Bezeichnung</InputLabel>
        <TextField id="brand" type="text" value={@state.brand} fullWidth className={if @state.brand == "" then "required" else ""} onChange={(ev) => @setState brand: ev.target?.value} />
        
        <FormControl>
          <InputLabel id="filling-label" shrink>Füllung</InputLabel>
          <Select labelId="filling-label" id="filling" value={@state.filling} onChange={(ev) => @setState filling: ev.target?.value}>
            <MenuItem value={0}>{'0g'}</MenuItem>
            <MenuItem value={50}>{'50g'}</MenuItem>
            <MenuItem value={100}>{'100g'}</MenuItem>
            <MenuItem value={150}>{'150g'}</MenuItem>
            <MenuItem value={200}>{'200g'}</MenuItem>
            <MenuItem value={250}>{'250g'}</MenuItem>
            <MenuItem value={300}>{'300g'}</MenuItem>
            <MenuItem value={350}>{'350g'}</MenuItem>
            <MenuItem value={400}>{'400g'}</MenuItem>
          </Select>
        </FormControl>

        <InputLabel id="color-label" margin="dense" shrink>Farbe</InputLabel>
        <Grid>
          {
            colors.map (color) => 
              <Radio key={'radio' + color} disableRipple style={{ color: color }} checked={@state.color == color} onChange={(ev) => @setState color: ev.target?.value} value={color} name="radio-button-color" />
          }
        </Grid>

        <DialogActions>
          <Button color="primary" onClick={=> @setState showForm: false, filling: 1, brand: "", color: "red"}> {'Abbrechen'} </Button>
          <AddNewButton brand={@state.brand} filling={@state.filling} color={@state.color} onClose={=> @setState showForm: false, filling: 0, brand: "", color: "red"} />
        </DialogActions>
      </Dialog>

      <RugList/>
    </Container>

export default Decken