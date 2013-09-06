// Generated by CoffeeScript 1.6.2
(function() {
  var asyncForEach, core, createBoxBillsData, createBoxesStoreTableData, createCableIncomeTableData, createCableUseTableData, createCopperIncomeBillsData, createCopperIncomeTableData, createCopperUseTableData, createItem, createLogObject, createLogsTableData, createOpticalIncomeBillsData, createOpticalIncomeTableData, createOpticalLogsTableData, createOpticalPlansTableData, createOpticalUseTableData, createpatchcordBillsData, createpatchcordesStoreTableData, createpatchpanelBillsData, createpatchpanelesStoreTableData, createpigtailsBillsData, createpigtailsesStoreTableData, createsocketsBillsData, createsocketsesStoreTableData, fs, getCurrentDateInMyFormat, prepareBuildingsInfo, replaceBuildingBoxesIDsWithObjects, replaceBuildingsIdWithBuildings, replaceStreetIdWithStreetNames, runResponse, writeImageToDisk;

  core = require('./core');

  fs = require('fs');

  replaceStreetIdWithStreetNames = function(buildings, streetnames) {
    var b, _i, _len;

    for (_i = 0, _len = buildings.length; _i < _len; _i++) {
      b = buildings[_i];
      b.street = streetnames.filter(function(e) {
        return e._id.toString() === b.street;
      })[0].name;
    }
    return buildings;
  };

  replaceBuildingsIdWithBuildings = function(items, buildings, params) {
    var i, param, _i, _j, _len, _len1;

    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      for (_j = 0, _len1 = params.length; _j < _len1; _j++) {
        param = params[_j];
        i[param] = buildings.filter(function(e) {
          return e._id.toString() === i[param];
        })[0];
      }
    }
    return items;
  };

  replaceBuildingBoxesIDsWithObjects = function(buildings, equipment) {
    var box, building, replace, _i, _j, _len, _len1, _ref;

    replace = function(data) {
      var elem, objects, _i, _len;

      objects = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        elem = data[_i];
        elem = equipment.filter(function(e) {
          return e._id.toString() === elem;
        })[0];
        objects.push(elem);
      }
      return objects;
    };
    for (_i = 0, _len = buildings.length; _i < _len; _i++) {
      building = buildings[_i];
      building.boxes = replace(building.boxes);
      _ref = building.boxes;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        box = _ref[_j];
        box.odf = replace(box.odf);
        box.upses = replace(box.upses);
        box.commutators = replace(box.commutators);
      }
    }
    return buildings;
  };

  asyncForEach = function(items, fn, callback) {
    var count, item, result, _i, _len, _results;

    result = {};
    count = 0;
    _results = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      item = items[_i];
      _results.push((function(item) {
        return fn(item, function(fnResult) {
          result[item] = fnResult;
          count++;
          if (count === items.length) {
            return callback(result);
          }
        });
      })(item));
    }
    return _results;
  };

  createCableUseTableData = function(items) {
    var i, rowdata, totalcableuse, values, _i, _len;

    totalcableuse = 0;
    values = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(i.contract);
      rowdata.push(i.users.toString());
      rowdata.push(i.cablewaste);
      rowdata.push(i.type);
      rowdata.push(i.manufacturer);
      rowdata.push(i.date.split("T")[0]);
      values.push(rowdata);
      totalcableuse += +i.cablewaste;
    }
    values.push(['Всього', '', totalcableuse, '', '', '']);
    return {
      "title": 'Звіт з використання кабелю',
      "headers": ['Номер договору', 'Монтажники', 'Кількість кабелю (м)', 'Тип', 'Марка', 'Дата'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createCableIncomeTableData = function(items) {
    var i, rowdata, totalcableincome, values, _i, _len;

    totalcableincome = 0;
    values = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(i.manufacturer);
      rowdata.push(i.type);
      rowdata.push(i.income);
      rowdata.push(i.date.split("T")[0]);
      values.push(rowdata);
      totalcableincome += +i.income;
    }
    values.push(['Всього', '', totalcableincome, '']);
    return {
      "title": 'Історія приходу кабеля',
      "headers": ['Виробник', 'Тип', 'Прихід', 'Дата'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createLogsTableData = function(items) {
    var i, rowdata, values, _i, _len;

    values = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(i.item);
      rowdata.push(i.action);
      rowdata.push(i.adress);
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.user);
      values.push(rowdata);
    }
    return {
      "title": 'Історія змін в обладнанні',
      "headers": ['Обладнання', 'Дія', 'Адреса', 'Дата', 'Користувач'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createCopperIncomeTableData = function(items, params) {
    var count, datarow, field, i, rowdata, values, _i, _j, _len, _len1, _ref;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      if (i.length !== 0) {
        datarow = {
          "id": i._id,
          "rowdata": ""
        };
        rowdata = [];
        rowdata.push(count);
        _ref = params.fields;
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          field = _ref[_j];
          rowdata.push(i[field]);
        }
        datarow.rowdata = rowdata;
        values.push(datarow);
        count++;
      }
    }
    return {
      "title": 'Наявний кабель',
      "headers": params.headers,
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createCopperUseTableData = function(items) {
    var i, rowdata, values, _i, _len;

    values = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.contract);
      rowdata.push(i.length);
      rowdata.push(i.workers);
      rowdata.push(i.user);
      values.push(rowdata);
    }
    return {
      "title": 'Використаний кабель',
      "headers": ['Дата', 'Призначення', 'Довжина (м)', 'Монтажники', 'Додав'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createOpticalIncomeTableData = function(items, params) {
    var count, datarow, field, i, rowdata, values, _i, _j, _len, _len1, _ref;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      if (i.length !== 0) {
        datarow = {
          "id": i._id,
          "rowdata": ""
        };
        rowdata = [];
        rowdata.push(count);
        _ref = params.fields;
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          field = _ref[_j];
          rowdata.push(i[field]);
        }
        datarow.rowdata = rowdata;
        values.push(datarow);
        count++;
      }
    }
    return {
      "title": 'Наявний кабель',
      "headers": params.headers,
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createOpticalPlansTableData = function(items, income_id) {
    var datarow, i, rowdata, values, _i, _len;

    items = items.filter(function(elem) {
      return elem.income_id.toString() === income_id;
    });
    values = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      datarow = {
        "id": i._id,
        "rowdata": ""
      };
      rowdata = [];
      rowdata.push(i.length);
      rowdata.push(i.intensions);
      rowdata.push(i.user);
      datarow.rowdata = rowdata;
      values.push(datarow);
    }
    return {
      planTableData: {
        "title": 'Заплановане використання',
        "headers": ['Довжина (м)', 'Призначення', 'Запланував', 'Виконати план', 'Видалити'],
        "values": values,
        "style": "table table-bordered table-hover table-condensed"
      },
      income_id: income_id
    };
  };

  createOpticalUseTableData = function(items) {
    var i, rowdata, values, _i, _len;

    values = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.intensions);
      rowdata.push(i.length);
      rowdata.push(i.workers);
      rowdata.push(i.user);
      values.push(rowdata);
    }
    return {
      "title": 'Виконані плани',
      "headers": ['Дата', 'Призначення', 'Довжина (м)', 'Монтажники', 'Додав'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createOpticalLogsTableData = function(items) {
    var i, rowdata, values, _i, _len;

    values = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(i.action);
      rowdata.push(i.length);
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.intensions);
      rowdata.push(i.cable);
      rowdata.push(i.user);
      values.push(rowdata);
    }
    return {
      "title": 'Лог змін',
      "headers": ['Дія', 'Довжина', 'Дата', 'Заплановане використання', 'Кабель', 'Користувач'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createOpticalIncomeBillsData = function(items) {
    var count, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(count);
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.fibers);
      rowdata.push(i.manufacturer);
      rowdata.push(i.initiallength);
      rowdata.push("<a href=javascript:document.forms['" + i.image + "'].submit()><img src='app/images/billsimgs/" + i.image + "'style='height: 30px; width: 30 px;' ></a><form method='get' id='" + i.image + "' action='/app/images/billsimgs/" + i.image + "'></form>");
      values.push(rowdata);
      count++;
    }
    return {
      "title": 'Фото накладних',
      "headers": ['№', 'Дата', 'Волокон', 'Виробник', 'Довжина(м)', 'Фото'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createCopperIncomeBillsData = function(items) {
    var count, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(count);
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.pairs);
      rowdata.push(i.manufacturer);
      rowdata.push(i.initiallength);
      rowdata.push("<a href=javascript:document.forms['" + i.image + "'].submit()><img src='/app/images/billsimgs/" + i.image + "'style='height: 30px; width: 30 px;' ></a><form method='get' id='" + i.image + "' action='/app/images/billsimgs/" + i.image + "'></form>");
      values.push(rowdata);
      count++;
    }
    return {
      "title": 'Фото накладних',
      "headers": ['№', 'Дата', 'Пар', 'Виробник', 'Довжина(м)', 'Фото'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createBoxesStoreTableData = function(items) {
    var count, datarow, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      if (i.quantity > 0) {
        datarow = {
          "id": i._id,
          "rowdata": ""
        };
        rowdata = [];
        rowdata.push(count);
        rowdata.push(i.box_name);
        rowdata.push(i.quantity);
        datarow.rowdata = rowdata;
        values.push(datarow);
        count++;
      }
    }
    return {
      "title": 'Коробки на складі',
      "headers": ['№', 'Тип', 'На складі', 'К-сть', 'Використати'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createBoxBillsData = function(items) {
    var count, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(count);
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.box_name);
      rowdata.push(i.init_quantity);
      rowdata.push("<a href=javascript:document.forms['" + i.image + "'].submit()><img src='/app/images/billsimgs/" + i.image + "'style='height: 30px; width: 30 px;' ></a><form method='get' id='" + i.image + "' action='/app/images/billsimgs/" + i.image + "'></form>");
      values.push(rowdata);
      count++;
    }
    return {
      "title": 'Фото накладних',
      "headers": ['№', 'Дата', 'Тип', 'К-сть', 'Фото'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createpatchpanelesStoreTableData = function(items) {
    var count, datarow, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      if (i.quantity > 0) {
        datarow = {
          "id": i._id,
          "rowdata": ""
        };
        rowdata = [];
        rowdata.push(count);
        rowdata.push(i.patchpanel_name);
        rowdata.push(i.quantity);
        datarow.rowdata = rowdata;
        values.push(datarow);
        count++;
      }
    }
    return {
      "title": 'Патч-панелі на складі',
      "headers": ['№', 'Тип', 'На складі', 'К-сть', 'Використати'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createpatchpanelBillsData = function(items) {
    var count, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(count);
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.patchpanel_name);
      rowdata.push(i.init_quantity);
      rowdata.push("<a href=javascript:document.forms['" + i.image + "'].submit()><img src='/app/images/billsimgs/" + i.image + "'style='height: 30px; width: 30 px;' ></a><form method='get' id='" + i.image + "' action='/app/images/billsimgs/" + i.image + "'></form>");
      values.push(rowdata);
      count++;
    }
    return {
      "title": 'Фото накладних',
      "headers": ['№', 'Дата', 'Тип', 'К-сть', 'Фото'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createpatchcordesStoreTableData = function(items) {
    var count, datarow, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      if (i.quantity > 0) {
        datarow = {
          "id": i._id,
          "rowdata": ""
        };
        rowdata = [];
        rowdata.push(count);
        rowdata.push(i.patchcord_length);
        rowdata.push(i.patchcord_types);
        rowdata.push(i.quantity);
        datarow.rowdata = rowdata;
        values.push(datarow);
        count++;
      }
    }
    return {
      "title": 'Патч-корди на складі',
      "headers": ['№', 'Довжина', 'Тип', 'На складі', 'К-сть', 'Використати'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createpatchcordBillsData = function(items) {
    var count, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(count);
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.patchcord_types);
      rowdata.push(i.init_quantity);
      rowdata.push("<a href=javascript:document.forms['" + i.image + "'].submit()><img src='/app/images/billsimgs/" + i.image + "'style='height: 30px; width: 30 px;' ></a><form method='get' id='" + i.image + "' action='/app/images/billsimgs/" + i.image + "'></form>");
      values.push(rowdata);
      count++;
    }
    return {
      "title": 'Фото накладних',
      "headers": ['№', 'Дата', 'Тип', 'К-сть', 'Фото'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createpigtailsesStoreTableData = function(items) {
    var count, datarow, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      if (i.quantity > 0) {
        datarow = {
          "id": i._id,
          "rowdata": ""
        };
        rowdata = [];
        rowdata.push(count);
        rowdata.push(i.pigtails_length);
        rowdata.push(i.pigtails_types);
        rowdata.push(i.quantity);
        datarow.rowdata = rowdata;
        values.push(datarow);
        count++;
      }
    }
    return {
      "title": 'Піг-тейли на складі',
      "headers": ['№', 'Довжина', 'Тип', 'На складі', 'К-сть', 'Використати'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createpigtailsBillsData = function(items) {
    var count, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(count);
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.pigtails_types);
      rowdata.push(i.init_quantity);
      rowdata.push("<a href=javascript:document.forms['" + i.image + "'].submit()><img src='/app/images/billsimgs/" + i.image + "'style='height: 30px; width: 30 px;' ></a><form method='get' id='" + i.image + "' action='/app/images/billsimgs/" + i.image + "'></form>");
      values.push(rowdata);
      count++;
    }
    return {
      "title": 'Фото накладних',
      "headers": ['№', 'Дата', 'Тип', 'К-сть', 'Фото'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createsocketsesStoreTableData = function(items) {
    var count, datarow, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      if (i.quantity > 0) {
        datarow = {
          "id": i._id,
          "rowdata": ""
        };
        rowdata = [];
        rowdata.push(count);
        rowdata.push(i.sockets_type);
        rowdata.push(i.quantity);
        datarow.rowdata = rowdata;
        values.push(datarow);
        count++;
      }
    }
    return {
      "title": 'Розетки на складі',
      "headers": ['№', 'Тип', 'На складі', 'К-сть', 'Використати'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  createsocketsBillsData = function(items) {
    var count, i, rowdata, values, _i, _len;

    values = [];
    count = 1;
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      i = items[_i];
      rowdata = [];
      rowdata.push(count);
      rowdata.push(i.date.split("T")[0]);
      rowdata.push(i.sockets_type);
      rowdata.push(i.init_quantity);
      rowdata.push("<a href=javascript:document.forms['" + i.image + "'].submit()><img src='/app/images/billsimgs/" + i.image + "'style='height: 30px; width: 30 px;' ></a><form method='get' id='" + i.image + "' action='/app/images/billsimgs/" + i.image + "'></form>");
      values.push(rowdata);
      count++;
    }
    return {
      "title": 'Фото накладних',
      "headers": ['№', 'Дата', 'Тип', 'К-сть', 'Фото'],
      "values": values,
      "style": "table table-bordered table-hover table-condensed"
    };
  };

  prepareBuildingsInfo = function(dbdata, building_id) {
    var building, prepareConnectionsInfo, prepareEquipmentInfo, prepareGeneralInfo;

    building = dbdata.buildings.filter(function(b) {
      return b._id.toString() === building_id;
    })[0];
    prepareGeneralInfo = function(building) {
      return {
        "name": building.street + ", " + building.number,
        "entrance": building.entrance,
        "type": building.type,
        "flat": building.flat,
        "ladder": building.ladder,
        "info": building.info
      };
    };
    prepareConnectionsInfo = function(building, connectors) {
      var c, incoming, outgoing, _i, _len;

      incoming = [];
      outgoing = [];
      for (_i = 0, _len = connectors.length; _i < _len; _i++) {
        c = connectors[_i];
        if (building._id === c.parent._id) {
          outgoing.push({
            "building_name": c.out.street + ", " + c.out.number,
            "type": c.type,
            "building_id": c.out._id
          });
        }
        if (building._id === c.out._id) {
          incoming.push({
            "building_name": c.parent.street + ", " + c.parent.number,
            "type": c.type,
            "building_id": c.parent._id
          });
        }
      }
      return {
        "outgoing_connections": outgoing,
        "incoming_connections": incoming
      };
    };
    prepareEquipmentInfo = function(building) {
      var box, commutators, equipmentinfo, odf, prepare, upses, _i, _len, _ref;

      prepare = function(data, params) {
        var d, elem, elems, param, _i, _j, _len, _len1;

        elems = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          d = data[_i];
          elem = {};
          for (_j = 0, _len1 = params.length; _j < _len1; _j++) {
            param = params[_j];
            elem[param] = d[param];
          }
          elems.push(elem);
        }
        return elems;
      };
      commutators = null;
      odf = null;
      upses = null;
      equipmentinfo = [];
      _ref = building.boxes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        box = _ref[_i];
        equipmentinfo.push({
          "box": {
            "_id": box._id,
            "name": box.name
          },
          "commutators": prepare(box.commutators, ['_id', 'name', 'free', 'manageable']),
          "odf": prepare(box.odf, ['_id', 'name', 'fotopath']),
          "upses": prepare(box.upses, ['_id', 'name'])
        });
      }
      return equipmentinfo;
    };
    return {
      "general": prepareGeneralInfo(building),
      "connections": prepareConnectionsInfo(building, dbdata.connectors),
      "equipment": prepareEquipmentInfo(building)
    };
  };

  createItem = function(req, db, callback) {
    var item, _id;

    item = null;
    switch (req.body.collection) {
      case "commutatornames":
        item = core.createCommutator({
          "name": req.body.name,
          "manageable": req.body.manageable,
          "free": 0
        });
        return callback(item);
      case "buildings":
        item = core.createBuilding({
          "type": req.body.item.type,
          "street": req.body.item.street,
          "number": req.body.item.number,
          "entrance": "",
          "flat": "",
          "ladder": "",
          "info": "",
          "boxes": []
        });
        return callback(item);
      case "connectors":
        return callback(core.createBuildingsConnector(req.body.item));
      case "cableincome":
        return callback({
          "income": req.body.data.income,
          "date": req.body.data.date,
          "manufacturer": req.body.data.manufacturer,
          "type": req.body.data.type
        });
      case "cableuse":
        return callback({
          "contract": req.body.data.contract,
          "cablewaste": req.body.data.cablewaste,
          "users": req.body.data.users,
          "date": req.body.data.date,
          "type": req.body.data.type,
          "manufacturer": req.body.data.manufacturer
        });
      case 'logs':
        item = req.body.data;
        item.user = req.session.login;
        return callback(item);
      case 'opticallogs':
        item = req.body.data;
        item.user = req.session.login;
        return db.getById('opticalincome', req.body.income_id, function(income) {
          var cable;

          cable = income[0].manufacturer + ", волокон : " + income[0].fibers;
          item.cable = cable;
          return callback(item);
        });
      case 'equipment':
        switch (req.body.type) {
          case 'box':
            _id = req.body._id;
            return db.getById('boxesnames', _id, function(box) {
              item = core.createBox({
                "name": box[0].name,
                "commutators": [],
                "upses": [],
                "odf": []
              });
              return callback(item);
            });
          case 'commutator':
            _id = req.body.data._id;
            return db.getById('commutatornames', _id, function(commutator) {
              item = core.createCommutator({
                "name": commutator[0].name,
                "free": 0,
                "manageable": false
              });
              return callback(item);
            });
          case 'mancommutator':
            _id = req.body.data._id;
            return db.getById('commutatornames', _id, function(commutator) {
              item = core.createManageableCommutator({
                "name": commutator[0].name,
                "ip": req.body.data.ip,
                "login": req.body.data.login,
                "pass": req.body.data.pass,
                "free": 0,
                "manageable": true
              });
              return callback(item);
            });
          case 'ups':
            _id = req.body.data._id;
            return db.getById('upsnames', _id, function(ups) {
              item = core.createUps({
                "name": ups[0].name
              });
              return callback(item);
            });
          case 'odf':
            _id = req.body.data._id;
            return db.getById('odfnames', _id, function(odf) {
              item = core.createODF({
                "name": odf[0].name
              });
              return callback(item);
            });
        }
        break;
      default:
        item = {
          "name": req.body.name
        };
        return callback(item);
    }
  };

  writeImageToDisk = function(path, data) {
    return fs.writeFile(path, data, function(err) {
      if (err) {
        console.log(err);
      }
      return console.log('written');
    });
  };

  createLogObject = function(item, action, user) {
    return core.createLogObject({
      "item": item,
      "action": action,
      "date": getCurrentDateInMyFormat(),
      "user": user
    });
  };

  runResponse = function(res, data, content_type) {
    res.setHeader('Content-Type', content_type);
    return res.end(JSON.stringify(data));
  };

  getCurrentDateInMyFormat = function() {
    var date, newdate;

    date = new Date().toISOString().substring(0, 10).split("-");
    newdate = date[2] + "-" + date[1] + "-" + date[0];
    return newdate;
  };

  module.exports.replaceStreetIdWithStreetNames = replaceStreetIdWithStreetNames;

  module.exports.replaceBuildingsIdWithBuildings = replaceBuildingsIdWithBuildings;

  module.exports.prepareBuildingsInfo = prepareBuildingsInfo;

  module.exports.createCableUseTableData = createCableUseTableData;

  module.exports.createCableIncomeTableData = createCableIncomeTableData;

  module.exports.asyncForEach = asyncForEach;

  module.exports.createItem = createItem;

  module.exports.runResponse = runResponse;

  module.exports.replaceBuildingBoxesIDsWithObjects = replaceBuildingBoxesIDsWithObjects;

  module.exports.createLogObject = createLogObject;

  module.exports.createLogsTableData = createLogsTableData;

  module.exports.createCopperIncomeTableData = createCopperIncomeTableData;

  module.exports.createCopperUseTableData = createCopperUseTableData;

  module.exports.createOpticalIncomeTableData = createOpticalIncomeTableData;

  module.exports.createOpticalPlansTableData = createOpticalPlansTableData;

  module.exports.createOpticalUseTableData = createOpticalUseTableData;

  module.exports.createOpticalLogsTableData = createOpticalLogsTableData;

  module.exports.createOpticalIncomeBillsData = createOpticalIncomeBillsData;

  module.exports.createCopperIncomeBillsData = createCopperIncomeBillsData;

  module.exports.createBoxesStoreTableData = createBoxesStoreTableData;

  module.exports.createBoxBillsData = createBoxBillsData;

  module.exports.createpatchpanelesStoreTableData = createpatchpanelesStoreTableData;

  module.exports.createpatchpanelBillsData = createpatchpanelBillsData;

  module.exports.createpatchcordesStoreTableData = createpatchcordesStoreTableData;

  module.exports.createpatchcordBillsData = createpatchcordBillsData;

  module.exports.createpigtailsesStoreTableData = createpigtailsesStoreTableData;

  module.exports.createpigtailsBillsData = createpigtailsBillsData;

  module.exports.createsocketsesStoreTableData = createsocketsesStoreTableData;

  module.exports.createsocketsBillsData = createsocketsBillsData;

}).call(this);