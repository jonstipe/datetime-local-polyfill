###
HTML5 DateTime-Local polyfill | Jonathan Stipe | https://github.com/jonstipe/datetime-local-polyfill
###
(($) ->
  $.fn.inputDateTimeLocal = ->
    readDateTime = (dt_str) ->
      if /^\d{4,}-\d\d-\d\dT\d\d:\d\d(?:\:\d\d(?:\.\d+)?)?$/.test dt_str
        matchData = /^(\d+)-(\d+)-(\d+)T(\d+):(\d+)(?:\:(\d+)(?:\.(\d+))?)?$/.exec dt_str
        yearPart = parseInt matchData[1], 10
        monthPart = parseInt matchData[2], 10
        dayPart = parseInt matchData[3], 10
        hourPart = parseInt matchData[4], 10
        minutePart = parseInt matchData[5], 10
        secondPart = if matchData[6]? then parseInt matchData[6], 10 else 0
        millisecondPart = if matchData[7]? then matchData[7] else '0'
        while millisecondPart.length < 3
	        millisecondPart += '0'
        millisecondPart = millisecondPart.substring 0, 3 if millisecondPart.length > 3
        millisecondPart = parseInt millisecondPart, 10
        dateObj = new Date()
        dateObj.setFullYear yearPart
        dateObj.setMonth monthPart - 1
        dateObj.setDate dayPart
        dateObj.setHours hourPart
        dateObj.setMinutes minutePart
        dateObj.setSeconds secondPart
        dateObj.setMilliseconds millisecondPart
        dateObj
      else
        throw "Invalid datetime string: #{dt_str}"

    makeDateTimeString = (date_obj) ->
      dt_arr = [date_obj.getFullYear().toString()]
      dt_arr.push '-'
      dt_arr.push '0' if date_obj.getMonth() < 9
      dt_arr.push (date_obj.getMonth() + 1).toString()
      dt_arr.push '-'
      dt_arr.push '0' if date_obj.getDate() < 10
      dt_arr.push date_obj.getDate().toString()
      dt_arr.push 'T'
      dt_arr.push '0' if date_obj.getHours() < 10
      dt_arr.push date_obj.getHours().toString()
      dt_arr.push ':'
      dt_arr.push '0' if date_obj.getMinutes() < 10
      dt_arr.push date_obj.getMinutes().toString()
      if date_obj.getSeconds() > 0 || date_obj.getMilliseconds() > 0
        dt_arr.push ':'
        dt_arr.push '0' if date_obj.getSeconds() < 10
        dt_arr.push date_obj.getSeconds().toString()
        if date_obj.getMilliseconds() > 0
          dt_arr.push '.'
          dt_arr.push '0' if date_obj.getMilliseconds() < 100
          dt_arr.push '0' if date_obj.getMilliseconds() < 10
          dt_arr.push date_obj.getMilliseconds().toString()
      dt_arr.join ''

    makeDateDisplayString = (date_obj, elem) ->
      $elem = $ elem
      day_names = $elem.datepicker "option", "dayNames"
      month_names = $elem.datepicker "option", "monthNames"
      date_arr = [day_names[date_obj.getDay()]]
      date_arr.push ', '
      date_arr.push month_names[date_obj.getMonth()]
      date_arr.push ' '
      date_arr.push date_obj.getDate().toString()
      date_arr.push ', '
      date_arr.push date_obj.getFullYear().toString()
      date_arr.join ''

    makeTimeDisplayString = (date_obj) ->
      time_arr = new Array()
      if date_obj.getHours() == 0
        time_arr.push '12'
        ampm = 'AM'
      else if date_obj.getHours() > 0 && date_obj.getHours() < 10
        time_arr.push '0'
        time_arr.push date_obj.getHours().toString()
        ampm = 'AM'
      else if date_obj.getHours() >= 10 && date_obj.getHours() < 12
        time_arr.push date_obj.getHours().toString()
        ampm = 'AM'
      else if date_obj.getHours() == 12
        time_arr.push '12'
        ampm = 'PM'
      else if date_obj.getHours() > 12 && date_obj.getHours() < 22
        time_arr.push '0'
        time_arr.push (date_obj.getHours() - 12).toString()
        ampm = 'PM'
      else if date_obj.getHours() >= 22
        time_arr.push (date_obj.getHours() - 12).toString()
        ampm = 'PM'
      time_arr.push ':'
      time_arr.push '0' if date_obj.getMinutes() < 10
      time_arr.push date_obj.getMinutes().toString()
      time_arr.push ':'
      time_arr.push '0' if date_obj.getSeconds() < 10
      time_arr.push date_obj.getSeconds().toString()
      if date_obj.getMilliseconds() > 0
        time_arr.push '.'
        if date_obj.getMilliseconds() % 100 == 0
          time_arr.push (date_obj.getMilliseconds() / 100).toString()
        else if date_obj.getMilliseconds() % 10 == 0
          time_arr.push '0'
          time_arr.push (date_obj.getMilliseconds() / 10).toString()
        else
          time_arr.push '0' if date_obj.getMilliseconds() < 100
          time_arr.push '0' if date_obj.getMilliseconds() < 10
          time_arr.push date_obj.getMilliseconds().toString()
      time_arr.push ' '
      time_arr.push ampm
      time_arr.join ''

    increment = (hiddenField, dateBtn, timeField, calendarDiv) ->
      $hiddenField = $ hiddenField
      value = readDateTime $hiddenField.val()
      step = $hiddenField.data "step"
      max = $hiddenField.data "max"
      if !step? || step == 'any'
        value.setSeconds value.getSeconds() + 1
      else
        value.setSeconds value.getSeconds() + step
      value.setTime max.getTime() if max? && value > max
      $hiddenField.val(makeDateTimeString(value)).change()
      $(dateBtn).text makeDateDisplayString(value, calendarDiv)
      $(timeField).val makeTimeDisplayString value
      $(calendarDiv).datepicker "setDate", value
      null

    decrement = (hiddenField, dateBtn, timeField, calendarDiv) ->
      $hiddenField = $ hiddenField
      value = readDateTime $hiddenField.val()
      step = $hiddenField.data "step"
      min = $hiddenField.data "min"
      if !step? || step == 'any'
        value.setSeconds value.getSeconds() - 1
      else
        value.setSeconds value.getSeconds() - step
      value.setTime min.getTime() if min? && value < min
      $hiddenField.val(makeDateTimeString(value)).change()
      $(dateBtn).text makeDateDisplayString(value, calendarDiv)
      $(timeField).val makeTimeDisplayString value
      $(calendarDiv).datepicker "setDate", value
      null

    incrementDate = (hiddenField, dateBtn, timeField, calendarDiv) ->
      $hiddenField = $ hiddenField
      value = readDateTime $hiddenField.val()
      step = $hiddenField.data "step"
      max = $hiddenField.data "max"
      value.setDate value.getDate() + 1
      value.setTime max.getTime() if max? && value > max
      $hiddenField.val(makeDateTimeString(value)).change()
      $(dateBtn).text makeDateDisplayString(value, calendarDiv)
      $(timeField).val makeTimeDisplayString value
      $(calendarDiv).datepicker "setDate", value
      null

    decrementDate = (hiddenField, dateBtn, timeField, calendarDiv) ->
      $hiddenField = $ hiddenField
      value = readDateTime $hiddenField.val()
      step = $hiddenField.data "step"
      min = $hiddenField.data "min"
      value.setDate value.getDate() - 1
      value.setTime min.getTime() if min? && value < min
      $hiddenField.val(makeDateTimeString(value)).change()
      $(dateBtn).text makeDateDisplayString(value, calendarDiv)
      $(timeField).val makeTimeDisplayString value
      $(calendarDiv).datepicker "setDate", value
      null

    stepNormalize = (inDate, hiddenField) ->
      $hiddenField = $ hiddenField
      step = $hiddenField.data "step"
      min = $hiddenField.data "min"
      max = $hiddenField.data "max"
      if step? && step != 'any'
        kNum = inDate.getTime()
        raisedStep = step * 1000
        min ?= new Date(0)
        minNum = min.getTime()
        stepDiff = (kNum - minNum) % raisedStep
        stepDiff2 = raisedStep - stepDiff
        if stepDiff == 0
          inDate
        else
          if stepDiff > stepDiff2
            new Date(inDate.getTime() + stepDiff2)
          else
            new Date(inDate.getTime() - stepDiff)
      else
        inDate

    $(this).filter('input[type="datetime-local"]').each ->
      $this = $ this
      value = $this.attr 'value'
      min = $this.attr 'min'
      max = $this.attr 'max'
      step = $this.attr 'step'
      className = $this.attr 'class'
      style = $this.attr 'style'
      if value? && /^\d{4,}-\d\d-\d\dT\d\d:\d\d(?:\:\d\d(?:\.\d+)?)?$/.test value
        value = readDateTime value
      else
        value = new Date()
      if min?
        min = readDateTime min
        value.setTime min.getTime() if value < min
      if max?
        max = readDateTime max
        value.setTime max.getTime() if value > max
      if step? and step != 'any'
        step = parseFloat step
      hiddenField = document.createElement 'input'
      $hiddenField = $ hiddenField
      $hiddenField.attr
        type: "hidden"
        name: $this.attr 'name'
        value: makeDateTimeString value
      $hiddenField.data
        min: min
        max: max
        step: step

      value = stepNormalize value, hiddenField
      $hiddenField.attr 'value', makeDateTimeString(value)

      calendarContainer = document.createElement 'span'
      $calendarContainer = $ calendarContainer
      $calendarContainer.attr 'class', className if className?
      $calendarContainer.attr 'style', style if style?
      calendarDiv = document.createElement 'div'
      $calendarDiv = $ calendarDiv
      $calendarDiv.css
        display: 'none'
        position: 'absolute'
      dateBtn = document.createElement 'button'
      $dateBtn = $ dateBtn
      $dateBtn.addClass 'datetime-local-datepicker-button'

      timeField = document.createElement 'input'
      $timeField = $ timeField
      $timeField.attr
        type: "text"
        value: makeTimeDisplayString value
        size: 14

      $this.replaceWith hiddenField
      $dateBtn.appendTo calendarContainer
      $calendarDiv.appendTo calendarContainer
      $calendarContainer.insertAfter hiddenField
      $timeField.insertAfter calendarContainer

      halfHeight = ($timeField.outerHeight() / 2) + 'px'
      upBtn = document.createElement 'div'
      $(upBtn)
        .addClass('datetime-local-spin-btn datetime-local-spin-btn-up')
        .css 'height', halfHeight
      downBtn = document.createElement 'div'
      $(downBtn)
        .addClass('datetime-local-spin-btn datetime-local-spin-btn-down')
        .css 'height', halfHeight
      btnContainer = document.createElement 'div'
      btnContainer.appendChild upBtn
      btnContainer.appendChild downBtn
      $(btnContainer).addClass('datetime-local-spin-btn-container').insertAfter timeField

      $calendarDiv.datepicker
        dateFormat: 'MM dd, yy'
        showButtonPanel: true

      $dateBtn.text makeDateDisplayString(value, calendarDiv)

      $calendarDiv.datepicker("option", "minDate", min) if min?
      $calendarDiv.datepicker("option", "maxDate", max) if max?
      if Modernizr.csstransitions
        calendarDiv.className = "datetime-local-calendar-dialog datetime-local-closed"
        $dateBtn.click (event) ->
          $calendarDiv.off 'transitionend oTransitionEnd webkitTransitionEnd MSTransitionEnd'
          calendarDiv.style.display = 'block'
          calendarDiv.className = "datetime-local-calendar-dialog datetime-local-open"
          event.preventDefault()
          false
        closeFunc = (event) ->
          if calendarDiv.className == "datetime-local-calendar-dialog datetime-local-open"
            transitionend_function = (event, ui) ->
              calendarDiv.style.display = 'none'
              $calendarDiv.off "transitionend oTransitionEnd webkitTransitionEnd MSTransitionEnd", transitionend_function
              null
            $calendarDiv.on "transitionend oTransitionEnd webkitTransitionEnd MSTransitionEnd", transitionend_function
            calendarDiv.className = "datetime-local-calendar-dialog datetime-local-closed"
          event.preventDefault() if event?
          null
      else
        $dateBtn.click (event) ->
          $calendarDiv.fadeIn 'fast'
          event.preventDefault()
          false
        closeFunc = (event) ->
          $calendarDiv.fadeOut 'fast'
          event.preventDefault() if event?
          null
      $calendarDiv.mouseleave closeFunc
      $calendarDiv.datepicker "option", "onSelect", (dateText, inst) ->
        origDate = readDateTime $hiddenField.val()
        dateObj = $.datepicker.parseDate 'MM dd, yy', dateText
        dateObj.setHours origDate.getHours()
        dateObj.setMinutes origDate.getMinutes()
        dateObj.setSeconds origDate.getSeconds()
        dateObj.setMilliseconds origDate.getMilliseconds()
        if min? && dateObj < min
          dateObj.setTime min.getTime()
        else if max? && dateObj > max
          dateObj.setTime max.getTime()
        dateObj = stepNormalize dateObj, hiddenField
        $hiddenField.val(makeDateTimeString(dateObj)).change()
        $timeField.val makeTimeDisplayString dateObj
        $dateBtn.text makeDateDisplayString(dateObj, calendarDiv)
        closeFunc()
        null
      $calendarDiv.datepicker "setDate", value
      $dateBtn.on
        DOMMouseScroll: (event) ->
          if event.originalEvent.detail < 0
            incrementDate hiddenField, dateBtn, timeField, calendarDiv
          else
            decrementDate hiddenField, dateBtn, timeField, calendarDiv
          event.preventDefault()
          null
        mousewheel: (event) ->
          if event.originalEvent.wheelDelta > 0
            incrementDate hiddenField, dateBtn, timeField, calendarDiv
          else
            decrementDate hiddenField, dateBtn, timeField, calendarDiv
          event.preventDefault()
          null
        keypress: (event) ->
          if event.keyCode == 38 # up arrow
            incrementDate hiddenField, dateBtn, timeField, calendarDiv
            event.preventDefault()
          else if event.keyCode == 40 # down arrow
            decrementDate hiddenField, dateBtn, timeField, calendarDiv
            event.preventDefault()
          null
      $timeField.on
        DOMMouseScroll: (event) ->
          if event.originalEvent.detail < 0
            increment hiddenField, dateBtn, timeField, calendarDiv
          else
            decrement hiddenField, dateBtn, timeField, calendarDiv
          event.preventDefault()
          null
        mousewheel: (event) ->
          if event.originalEvent.wheelDelta > 0
            increment hiddenField, dateBtn, timeField, calendarDiv
          else
            decrement hiddenField, dateBtn, timeField, calendarDiv
          event.preventDefault()
          null
        keypress: (event) ->
          if event.keyCode == 38 # up arrow
            increment hiddenField, dateBtn, timeField, calendarDiv
            event.preventDefault()
          else if event.keyCode == 40 # down arrow
            decrement hiddenField, dateBtn, timeField, calendarDiv
            event.preventDefault()
          else if event.keyCode not in [35, 36, 37, 39, 46] && 
               event.which not in [8, 9, 32, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 65, 77, 80, 97, 109, 112]
            event.preventDefault()
          null
        change: (event) ->
          $this = $ this
          if /^((?:1[0-2])|(?:0[1-9]))\:[0-5]\d(?:\:[0-5]\d(?:\.\d+)?)?\s[AaPp][Mm]$/.test $this.val()
            matchData = /^(\d\d):(\d\d)(?:\:(\d\d)(?:\.(\d+))?)?\s([AaPp][Mm])$/.exec $this.val()
            hours = parseInt matchData[1], 10
            minutes = parseInt matchData[2], 10
            seconds = parseInt(matchData[3], 10) || 0
            milliseconds = matchData[4]
            unless milliseconds?
              milliseconds = 0
            else if milliseconds.length > 3
              milliseconds = parseInt milliseconds.substring(0, 3), 10
            else if milliseconds.length < 3
              while milliseconds.length < 3
                milliseconds += '0'
              milliseconds = parseInt milliseconds, 10
            else
              milliseconds = parseInt milliseconds, 10
            ampm = matchData[5].toUpperCase()
            dateObj = readDateTime $hiddenField.val()
            if ampm == 'AM' && hours == 12
              hours = 0
            else if ampm == 'PM' && hours != 12
              hours += 12
            dateObj.setHours hours
            dateObj.setMinutes minutes
            dateObj.setSeconds seconds
            dateObj.setMilliseconds milliseconds
            if min? && dateObj < min
              $hiddenField.val(makeDateTimeString(min)).change()
              $this.val makeTimeDisplayString(min)
            else if max? && dateObj > max
              $hiddenField.val(makeDateTimeString(max)).change()
              $this.val makeTimeDisplayString(max)
            else
              dateObj = stepNormalize dateObj, hiddenField
              $hiddenField.val(makeDateTimeString(dateObj)).change()
              $this.val makeTimeDisplayString(dateObj)
          else
            $this.val makeTimeDisplayString readDateTime $hiddenField.val()
          null
      $(upBtn).on "mousedown", (event) ->
        increment hiddenField, dateBtn, timeField, calendarDiv

        timeoutFunc = (hiddenField, dateBtn, timeField, calendarDiv, incFunc) ->
          incFunc hiddenField, dateBtn, timeField, calendarDiv
          $(timeField).data 'timeoutID', window.setTimeout(timeoutFunc, 10, hiddenField, dateBtn, timeField, calendarDiv, incFunc)
          null

        releaseFunc = (event) ->
          window.clearTimeout $(timeField).data('timeoutID')
          $(document).off 'mouseup', releaseFunc
          $(upBtn).off 'mouseleave', releaseFunc
          null

        $(document).on 'mouseup', releaseFunc
        $(upBtn).on 'mouseleave', releaseFunc

        $(timeField).data 'timeoutID', window.setTimeout(timeoutFunc, 700, hiddenField, dateBtn, timeField, calendarDiv, increment)
        null
      $(downBtn).on "mousedown", (event) ->
        decrement hiddenField, dateBtn, timeField, calendarDiv

        timeoutFunc = (hiddenField, dateBtn, timeField, calendarDiv, decFunc) ->
          decFunc hiddenField, dateBtn, timeField, calendarDiv
          $(timeField).data 'timeoutID', window.setTimeout(timeoutFunc, 10, hiddenField, dateBtn, timeField, calendarDiv, decFunc)
          null

        releaseFunc = (event) ->
          window.clearTimeout $(timeField).data('timeoutID')
          $(document).off 'mouseup', releaseFunc
          $(downBtn).off 'mouseleave', releaseFunc
          null

        $(document).on 'mouseup', releaseFunc
        $(downBtn).on 'mouseleave', releaseFunc

        $(timeField).data 'timeoutID', window.setTimeout(timeoutFunc, 700, hiddenField, dateBtn, timeField, calendarDiv, decrement)
        null
      null
    this
  $ ->
    $('input[type="datetime-local"]').inputDateTimeLocal() unless Modernizr.inputtypes["datetime-local"]
    null
  null
)(jQuery)