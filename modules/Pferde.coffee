`
import React, { Component, useState, useEffect } from 'react'
import { useIndexedDB } from 'react-indexed-db';
import * as _ from 'lodash';
import { Avatar, Button, Container, Dialog, DialogActions, Divider, Fab, FormControl, Icon, InputLabel, List, ListItem, ListItemAvatar, ListItemText, MenuItem, Select, TextField, Typography } from '@material-ui/core';
import SwipeToDelete from 'react-swipe-to-delete-component';
`

AddNewButton = (props) ->
  { add } = useIndexedDB('Pferd')
 
  handleClick = () =>
    if props.formValues?.name !=""
      (if props.formValues?.file?
        new Promise (resolve, reject) ->
          reader = new FileReader()
          reader.addEventListener "load", (-> resolve(reader.result)), false
          reader.readAsDataURL(props.formValues?.file)
      else
        Promise.resolve null
      ).then (img) =>
        add { name: props.formValues?.name, sensibility: props.formValues?.sensibility, foto: img }
          .then(
            (event) => props.onClose()
            (error) => console.error error
          )

  <Button onClick={handleClick} color="primary"> {'Speichern'} </Button>


HorseList = (props) ->
  { getAll, deleteRecord } = useIndexedDB('Pferd');
  [horses, setHorses] = useState();
 
  useEffect => 
    getAll()
      .then (horsesFromDB) => setHorses(horsesFromDB) if horses?.length != horsesFromDB?.length

  deleteHorse = ({ item: horse }) =>
    deleteRecord(horse.id).then => setHorses(_.reject(horses, { id: horse.id }))
 
  if horses? && horses?.length > 0
    <List dense>
      {
        _.sortBy(horses, 'name').map (horse) => 
          [
            <SwipeToDelete key={horse.id} item={horse} onDelete={deleteHorse} deleteSwipe={0.3}>
              <ListItem key={'horse' + horse.id}>   
                <ListItemAvatar>
                  <Avatar className="horse" src={horse.foto}>{horse.name[0]}</Avatar>
                </ListItemAvatar>
                <ListItemText id={horse.name} primary={horse.name} secondary={['Robust', 'Empfindlich', 'Absolute Frostbeule'][horse.sensibility - 1]} />
              </ListItem>
              <Divider key={'horseDiv' + horse.id} />
            </SwipeToDelete>
          ]
      }
    </List>
  else
    <Typography variant="body1">Noch kein Pferd angelegt.</Typography>


class Pferde extends Component
  constructor: ->
    super()
    @state =
      showForm: false
      sensibility: 1
      name: ""
      file: null

  render: ->
    <Container component="div" className="content" maxWidth="sm">
      <Typography variant="h2" component="h2" className="heading" gutterBottom>
        {'Pferde'}
        <Fab color="primary" size="small" aria-label="add" onClick={=> @setState showForm: true} style={{ marginLeft: '30px' }}>
          <Icon className="fas fa-plus"/>
        </Fab>
      </Typography>

      <Dialog open={@state.showForm} onClose={=> @setState showForm: false}>
        <InputLabel id="name-label" margin="dense" shrink>Name</InputLabel>
        <TextField id="name" type="text" value={@state.name} fullWidth className={if @state.name == "" then "required" else ""} onChange={(ev) => @setState name: ev.target?.value} />
        
        <FormControl>
          <InputLabel id="sensibility-label" shrink>Empfindlichkeit</InputLabel>
          <Select labelId="sensibility-label" id="sensibility" value={@state.sensibility} onChange={(ev) => @setState sensibility: ev.target?.value}>
            <MenuItem value={1}>Robust</MenuItem>
            <MenuItem value={2}>Empfindlich</MenuItem>
            <MenuItem value={3}>Absolute Frostbeule</MenuItem>
          </Select>
        </FormControl>

        <InputLabel id="file-label" margin="dense" shrink>Foto</InputLabel>
        <TextField accept="image/*" id="horse-pic-file" type="file" onChange={(ev) => @setState file: ev.target?.files?[0]} />

        <DialogActions>
          <Button color="primary" onClick={=> @setState showForm: false, sensibility: 1, name: "", file: null}> {'Abbrechen'} </Button>
          <AddNewButton formValues={@state} onClose={=> @setState showForm: false, sensibility: 1, name: "", file: null} />
        </DialogActions>
      </Dialog>

      <HorseList/>
    </Container>

export default Pferde