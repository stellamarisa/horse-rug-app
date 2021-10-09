// Generated by CoffeeScript 2.6.1

import React, { Component, useState, useEffect } from 'react'
import { useIndexedDB } from 'react-indexed-db'
import moment from 'moment'
import * as _ from 'lodash'
import { Avatar, Collapse, Container, Divider, Icon, List, ListItem, ListItemAvatar, ListItemText, ListSubheader, Typography } from '@material-ui/core';
;
var Days, Decken, DeckenDetails, WetterDetails, getPerfectRug, rainLimit, rugMeasurement, tempMeasurement;

rugMeasurement = [
  function(temp) {
    return -1; // unused
  },
  function(temp) {
    return -13.3 * temp + 133; // robust
  },
  function(temp) {
    return -20.5 * temp + 247; // empfindlich
  },
  function(temp) {
    return -17.6 * temp + 262; // Frostbeule
  }
];

tempMeasurement = [
  function(filling) {
    return 0; // unused
  },
  function(filling) {
    return (filling - 133) / -13.3; // robust
  },
  function(filling) {
    return (filling - 247) / -20.5; // empfindlich
  },
  function(filling) {
    return (filling - 262) / -17.6; // Frostbeule
  }
];

rainLimit = [0, 12, 15, 15];

getPerfectRug = (sensibility, rugs, day) => {
  var fillingAvg, ref, ref1, ref2, ref3;
  fillingAvg = rugMeasurement[sensibility]((day.minTemp + day.maxTemp) / 2);
  
  // Regengrenze beachten
  if (fillingAvg < 0 && day.minTemp <= rainLimit[sensibility] && (((ref = day.weather) != null ? (ref1 = ref[0]) != null ? ref1.main : void 0 : void 0) === "Snow" || ((ref2 = day.weather) != null ? (ref3 = ref2[0]) != null ? ref3.main : void 0 : void 0) === "Rain")) {
    return _.minBy(rugs, 'filling');
  } else if (fillingAvg < 0) {
    return {
      color: "#fafafa",
      fontColor: "darkgrey",
      brand: "Keine Decke"
    };
  } else {
    return _.reduce(rugs, function(prev, curr) {
      if (Math.abs(curr.filling - fillingAvg) < Math.abs(prev.filling - fillingAvg)) {
        return curr;
      } else {
        return prev;
      }
    }, rugs[0]);
  }
};

DeckenDetails = (props) => {
  var diffDay, diffNight, perfectTemp, text1, text2;
  perfectTemp = tempMeasurement[props.sensibility](props.rug.filling);
  diffNight = Math.round(perfectTemp - props.day.minTemp);
  diffDay = Math.round(perfectTemp - props.day.maxTemp);
  text1 = <small>{`${props.rug.brand} (${props.rug.filling} g)`}</small>;
  text2 = <small>
      {`Nachts ${Math.abs(diffNight)}°C zu ${(diffNight > 0 && "kalt") || "warm"}, tagsüber ${Math.abs(diffDay)}°C zu ${(diffDay > 0 && "kalt") || "warm"}`}
    </small>;
  return <ListItem>
    <ListItemText id={props.rug.id} primary={text1} secondary={text2} style={{
    margin: 0
  }} />
  </ListItem>;
};

WetterDetails = (props) => {
  return <>
    <span key={'WetterDetails1' + props.day.dt} style={{
    display: 'block'
  }}>
      {moment(props.day.dt * 1000).format("L")}
    </span>
    <span key={'WetterDetails2' + props.day.dt} style={{
    display: 'block'
  }}>
      min. {props.day.minTemp}°C / max. {props.day.maxTemp}°C
    </span>
  </>;
};

Days = function(props) {
  var getAll, getAllHorses, getAllRugs, horses, open, ref, ref1, rugs, setHorses, setOpen, setRugs;
  ({getAll} = useIndexedDB('Decke'));
  getAllRugs = getAll;
  ({getAll} = useIndexedDB('Pferd'));
  getAllHorses = getAll;
  [rugs, setRugs] = useState();
  [horses, setHorses] = useState();
  [open, setOpen] = useState(0);
  useEffect(() => {
    getAllRugs().then((rugsFromDB) => {
      if ((rugs != null ? rugs.length : void 0) !== (rugsFromDB != null ? rugsFromDB.length : void 0)) {
        return setRugs(_.sortBy(rugsFromDB, 'filling'));
      }
    });
    return getAllHorses().then((horsesFromDB) => {
      if ((horses != null ? horses.length : void 0) !== (horsesFromDB != null ? horsesFromDB.length : void 0)) {
        return setHorses(_.sortBy(horsesFromDB, 'name'));
      }
    });
  });
  if ((rugs != null) && (rugs != null ? rugs.length : void 0) > 0 && (horses != null) && (horses != null ? horses.length : void 0) > 0) {
    if (props.weatherResponse === "load") {
      return <Typography variant="body1">Wetter wird geladen...</Typography>;
    } else if ((props.weatherResponse != null) && ((ref = props.weatherResponse) != null ? (ref1 = ref.daily) != null ? ref1.length : void 0 : void 0) > 0) {
      return <List dense disablePadding>
          {horses.map(function(horse) {
        var ref2;
        return <React.Fragment key={horse.name}>
                <ListSubheader style={{
          backgroundColor: "#fafafa",
          paddingBottom: "10px"
        }}>
                  <Typography variant="subtitle1" gutterBottom>{horse.name}</Typography>
                </ListSubheader>
                {_.sortBy((ref2 = props.weatherResponse) != null ? ref2.daily : void 0, 'dt').map((day) => {
          var perfectRug, ref3, ref4, ref5, ref6, ref7, ref8;
          day.minTemp = Math.round((ref3 = day.feels_like) != null ? ref3.morn : void 0);
          day.maxTemp = Math.round((ref4 = day.feels_like) != null ? ref4.day : void 0);
          perfectRug = getPerfectRug(horse.sensibility, rugs, day);
          return <React.Fragment key={day.dt}>
                      <ListItem button onClick={function() {
            return setOpen(open === day.dt ? 0 : day.dt);
          }}>   
                        <ListItemAvatar>
                          <Avatar style={{
            backgroundColor: perfectRug.color,
            color: perfectRug.fontColor
          }}>{moment(day.dt * 1000).format("dd")}</Avatar>
                        </ListItemAvatar>
                        <ListItemText id={day.dt} primary={perfectRug.brand} secondary={<WetterDetails day={day} />} />
                        {((ref5 = day.weather) != null ? (ref6 = ref5[0]) != null ? ref6.main : void 0 : void 0) === "Rain" ? <Icon className="fas fa-cloud-showers-heavy" style={{
            fontSize: 18,
            marginRight: 20,
            width: 20
          }} /> : void 0}
                        {((ref7 = day.weather) != null ? (ref8 = ref7[0]) != null ? ref8.main : void 0 : void 0) === "Snow" ? <Icon className="fas fa-snowflake" style={{
            fontSize: 18,
            marginRight: 20,
            width: 20
          }} /> : void 0}
                        <Icon className={`fas fa-chevron-${open === day.dt ? 'up' : 'down'}`} style={{
            fontSize: 15
          }} /> 
                      </ListItem>
                      <Collapse in={open === day.dt} timeout="auto">
                        {rugs.map(function(rug) {
            return <DeckenDetails key={"DeckenDetails" + rug.id} rug={rug} day={day} sensibility={horse.sensibility} />;
          })}
                      </Collapse>
                      <Divider />
                    </React.Fragment>;
        })}
                <ListItem style={{
          height: "100px"
        }} />
              </React.Fragment>;
      })}
        </List>;
    } else {
      return <Typography variant="body1">Das Wetter konnte nicht abgefragt werden.</Typography>;
    }
  } else {
    return [<Typography key="Typography1" variant="h5" component="h5" gutterBottom>Finde heraus, welche Decke dein Pferd heute braucht!</Typography>, <Typography key="Typography2" variant="body1">Wähle eines der Symbole unten.</Typography>, <Typography key="Typography3" variant="body1">Du musst mindestens ein Pferd und eine Decke anlegen, um eine Empfehlung zu bekommen.</Typography>];
  }
};

Decken = class Decken extends Component {
  constructor() {
    super();
    this.state = {
      showForm: false,
      filling: 100,
      brand: "",
      color: "red"
    };
  }

  render() {
    return <Container component="div" className="content" maxWidth="sm">
      <Typography variant="h2" component="h2" className="heading" gutterBottom>
        {'Empfehlung'}
      </Typography>

      <Days weatherResponse={this.props.weatherResponse} />
    </Container>;
  }

};

export default Decken;
