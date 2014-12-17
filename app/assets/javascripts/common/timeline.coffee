(($, moment) ->
  $.fn.timeline = (events) ->
    $eventsTag = $("<div class='events'></div>").appendTo(this)
    $buttonLeft = $("<div class='moveLeft'>
                      <button type='button' class='btn btn-success btn-lg'>
                        <span class='glyphicon glyphicon-arrow-left'>
                        </span>
                      </button>
                    </div>").appendTo(this)
    $buttonRight = $("<div class='moveRight'>
                      <button type='button' class='btn btn-success btn-lg'>
                        <span class='glyphicon glyphicon-arrow-right'>
                        </span>
                      </button>
                    </div>").appendTo(this)

    timeline =
      $el: $eventsTag
      $leftArrow: $buttonLeft
      $rightArrow: $buttonRight

      config:
        dayLength: 7

      render: ->
        [firstDate, lastDate] = @getLimits()
        @setEnds(firstDate, lastDate)
        @renderHtml()

      renderHtml: ->
        html = @renderMonths()
        html += @renderToDay()
        html += @renderEvent(e) for e in events
        @$el.html(html)

      getLimits: ->
        firstDate = new Date()
        lastDate = firstDate

        for e in events
          startDate = new Date(e.startDate)
          if startDate < firstDate
            firstDate = startDate
          else if lastDate < startDate
            lastDate = startDate
        [firstDate, lastDate]

      setEnds: (firstDate, lastDate) ->
        @endTimelineM = moment(lastDate).add(2, 'months')
        @startTimelineM = moment(lastDate).subtract(3, 'months')
        @startTimelineM.startOf "month"
        @endTimelineM.endOf "month"

      renderEvent: (event) ->
        offset = @eventOffset(moment(event.startDate))
        width = @eventWidth(event)
        oldClass = if @eventIsOld(event) then 'event-old' else ''
        "<div class='event #{oldClass}' style='margin-left: #{offset}px'>
          <div class='time' style='width: #{width}px'></div>
          #{@renderEventTitle(event)}
        </div>"

      eventIsOld: (event) ->
        moment(event.endDate).isBefore(new Date());

      isBillable: (event) ->
        if event.billable
          "<div class='glyphicon glyphicon-euro img-circle billable'></div>"
        else
          ''

      renderEventTitle: (event) ->
        display = (date) -> moment(event[date]).format "D MMM YYYY"
        endDate = -> if event.endDate then display('endDate') else 'not expired'
        billable = @isBillable(event)
        eventTitle = billable
        eventTitle += "<span>#{display('startDate')}"
        eventTitle += " - #{endDate()}" if event.startDate != event.endDate
        eventTitle += "</span> <a href='#{Routes.user_path(event.user_id)}'>#{event.text}</a>&nbsp;&nbsp;"

      renderMonths: ->
        [html, width, days] = ["", 0, 0]
        months = @endTimelineM.diff(@startTimelineM, 'months')
        titleDateM = moment(@startTimelineM)
        prevDate = titleDateM
        for n in [0..months]
          html += "<section class='month' style='left: #{width}px'>#{titleDateM.format("MMMM YYYY")}</section>"
          days += prevDate.daysInMonth()
          width = @daysLength(days)
          prevDate = titleDateM
          titleDateM.add("months", 1)
        html

      renderToDay: ->
        offset = this.daysDiff(moment(new Date()), this.startTimelineM)
        toDay = moment(new Date()).format "D MMM"
        "<section class='month today' style='left: #{@daysLength(offset)}px'>
          <div class='today-inline'>
            <p class='title'>Today</p>
            <p class='date'>#{toDay}</p>
          </div>
        </section>"

      eventOffset: (startDateM) ->
        daysDiff = @daysDiff(startDateM, @startTimelineM)
        @daysLength(daysDiff)

      eventWidth: (event) ->
        startDate = event.startDate
        endDate = event.endDate
        endTimelineMCopy = @endTimelineM.clone()
        if endDate && moment(endDate).isBefore(@endTimelineM)
          daysDiff = @daysDiff(moment(endDate), moment(startDate))
        else
          endDate = endTimelineMCopy.subtract(1, 'months')
          daysDiff = @daysDiff(endDate, moment(startDate)) + 1
        @daysLength(daysDiff)


      daysLength: (days) -> (days * @config.dayLength).toFixed(2)

      daysDiff: (firstDateM, secondDate) -> firstDateM.diff(secondDate, 'days')

      moveLeft: ->
        @$leftArrow.click (event) =>
          @endTimelineM = moment(@endTimelineM).subtract(3, 'months')
          @startTimelineM = moment(@startTimelineM).subtract(3, 'months')
          @renderHtml()

      moveRight: ->
        @$rightArrow.click (event) =>
          @endTimelineM = moment(@endTimelineM).add(3, 'months')
          @startTimelineM = moment(@startTimelineM).add(3, 'months')
          @renderHtml()

    slider =
      $el: $eventsTag.parent()
      startingMousePostition: {}
      startingPagePosition: {}

      init: ->
        @$el.mousedown (event) =>
          @startingMousePostition =
            x: event.clientX
            y: event.clientY

          @startingPagePosition =
            x: @$el.scrollLeft()
            y: @$el.scrollTop()

          @$el.mousemove(@slide.bind(this))

        @$el.mouseup (event) => @$el.off('mousemove')

      slide: (event) ->
        event.preventDefault()
        x = @startingPagePosition.x + (@startingMousePostition.x - event.clientX)
        y = @startingPagePosition.y + (@startingMousePostition.y - event.clientY)
        @$el.scrollTo(x, y)

    timeline.render()
    timeline.moveLeft()
    timeline.moveRight()
    slider.init()
    this
) jQuery, moment
