from PySide6.QtCore import QObject, Property, Signal

class Study(QObject):
    def __init__(self, study_data=None, parent=None):
        super().__init__(parent)
        self._study_id = study_data.get('study_id', -1) if study_data else -1
        self._study_code = study_data.get('study_code', '') if study_data else ''
        self._title = study_data.get('title', '') if study_data else ''
        self._description = study_data.get('description', '') if study_data else ''
        self._start_date = study_data.get('start_date', '') if study_data else ''
        self._end_date = study_data.get('end_date', '') if study_data else ''
        self._status = study_data.get('status', 'planned') if study_data else 'planned'

    # Properties
    studyIdChanged = Signal()
    @Property(int, notify=studyIdChanged)
    def studyId(self):
        return self._study_id

    studyCodeChanged = Signal()
    @Property(str, notify=studyCodeChanged)
    def studyCode(self):
        return self._study_code

    titleChanged = Signal()
    @Property(str, notify=titleChanged)
    def title(self):
        return self._title

    descriptionChanged = Signal()
    @Property(str, notify=descriptionChanged)
    def description(self):
        return self._description

    startDateChanged = Signal()
    @Property(str, notify=startDateChanged)
    def startDate(self):
        return self._start_date

    endDateChanged = Signal()
    @Property(str, notify=endDateChanged)
    def endDate(self):
        return self._end_date

    statusChanged = Signal()
    @Property(str, notify=statusChanged)
    def status(self):
        return self._status

    def update(self, study_data):
        self._study_id = study_data.get('study_id', self._study_id)
        self._study_code = study_data.get('study_code', self._study_code)
        self._title = study_data.get('title', self._title)
        self._description = study_data.get('description', self._description)
        self._start_date = study_data.get('start_date', self._start_date)
        self._end_date = study_data.get('end_date', self._end_date)
        self._status = study_data.get('status', self._status)

        # Emit all change signals
        self.studyIdChanged.emit()
        self.studyCodeChanged.emit()
        self.titleChanged.emit()
        self.descriptionChanged.emit()
        self.startDateChanged.emit()
        self.endDateChanged.emit()
        self.statusChanged.emit()
