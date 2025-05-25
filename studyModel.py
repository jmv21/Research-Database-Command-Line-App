from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex
from study import Study

class StudyListModel(QAbstractListModel):
    def __init__(self, studies=None, parent=None):
        super().__init__(parent)
        self._studies = studies or []

    def rowCount(self, parent=QModelIndex()):
        return len(self._studies)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self._studies):
            return None

        study = self._studies[index.row()]
        roles = {
            Qt.UserRole + 1: study.studyId,
            Qt.UserRole + 2: study.studyCode,
            Qt.UserRole + 3: study.title,
            Qt.UserRole + 4: study.description,
            Qt.UserRole + 5: study.startDate,
            Qt.UserRole + 6: study.endDate,
            Qt.UserRole + 7: study.status
        }
        return roles.get(role)

    def roleNames(self):
        return {
            Qt.UserRole + 1: b"studyId",
            Qt.UserRole + 2: b"studyCode",
            Qt.UserRole + 3: b"title",
            Qt.UserRole + 4: b"description",
            Qt.UserRole + 5: b"startDate",
            Qt.UserRole + 6: b"endDate",
            Qt.UserRole + 7: b"status"
        }

    def addStudy(self, study_data):
        self.beginInsertRows(QModelIndex(), len(self._studies), len(self._studies))
        self._studies.append(Study(study_data))
        self.endInsertRows()

    def updateStudy(self, index, study_data):
        if 0 <= index < len(self._studies):
            self._studies[index].update(study_data)
            self.dataChanged.emit(self.index(index), self.index(index))

    def removeStudy(self, index):
        if 0 <= index < len(self._studies):
            self.beginRemoveRows(QModelIndex(), index, index)
            del self._studies[index]
            self.endRemoveRows()

    def clear(self):
        self.beginResetModel()
        self._studies = []
        self.endResetModel()

    @property
    def studies(self):
        return self._studies
