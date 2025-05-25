import json
from pathlib import Path
from PySide6.QtCore import QObject, Property, Signal, Slot, QUrl

class QuickCommand(QObject):
    def __init__(self, cmd_id: str, title: str, description: str, sql: str, parent=None):
        super().__init__(parent)
        self._cmd_id = cmd_id
        self._title = title
        self._description = description
        self._sql = sql

    # Properties
    @Property(str, constant=True)
    def cmd_id(self):
        return self._cmd_id

    @Property(str, constant=True)
    def title(self):
        return self._title

    @Property(str, constant=True)
    def description(self):
        return self._description

    @Property(str, constant=True)
    def sql(self):
        return self._sql


class QuickCommandModel(QObject):
    commandsChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._commands = []
        self._load_commands()

    def _load_commands(self):
        """Load commands from JSON if available, otherwise use defaults"""
        json_path = Path("quick_commands.json")

        if json_path.exists():
            try:
                with open(json_path, 'r', encoding='utf-8') as f:
                    commands = json.load(f)
                self._notification_loaded = True
            except Exception as e:
                print(f"Error loading quick commands JSON: {e}")
                commands = self._get_default_commands()
        else:
            commands = self._get_default_commands()

        for cmd in commands:
            self._commands.append(QuickCommand(
                cmd["id"],
                cmd["title"],
                cmd["description"],
                cmd["sql"],
                self
            ))


    def _get_default_commands(self):
            return [
                {
                    "id": "active_subjects",
                    "title": "Active Subjects",
                    "description": "List all active subjects with their species",
                    "sql": """SELECT s.lab_id, sp.common_name, s.sex, s.birth_date
                              FROM subjects s
                              JOIN species sp ON s.species_id = sp.species_id
                              WHERE s.status = 'active'"""
                },
                {
                    "id": "compound_usage",
                    "title": "Compound Usage Summary",
                    "description": "Efficiently shows total usage of each compound across all studies",
                    "sql": """
                        SELECT
                            c.compound_name,
                            COUNT(sc.subject_condition_id) as total_uses,
                            COUNT(DISTINCT ec.study_id) as studies_used_in,
                            COUNT(DISTINCT sc.subject_id) as subjects_treated
                        FROM compounds c
                        LEFT JOIN (
                            SELECT
                                dd.compound_id,
                                sc.subject_condition_id,
                                sc.subject_id,
                                sc.condition_id
                            FROM dosage_definitions dd
                            JOIN subject_conditions sc ON dd.dosage_id = sc.dosage_id
                        ) sc ON c.compound_id = sc.compound_id
                        LEFT JOIN experimental_conditions ec ON sc.condition_id = ec.condition_id
                        GROUP BY c.compound_id
                        ORDER BY total_uses DESC
                    """
                },
                {
                    "id": "subject_status",
                    "title": "Subject Status Report",
                    "description": "Current status of all subjects with their last treatment",
                    "sql": """
                        SELECT
                            s.lab_id,
                            sp.common_name as species,
                            s.status,
                            MAX(sc.administration_time) as last_treatment,
                            c.compound_name as last_compound
                        FROM subjects s
                        JOIN species sp ON s.species_id = sp.species_id
                        LEFT JOIN subject_conditions sc ON s.subject_id = sc.subject_id
                        LEFT JOIN dosage_definitions dd ON sc.dosage_id = dd.dosage_id
                        LEFT JOIN compounds c ON dd.compound_id = c.compound_id
                        GROUP BY s.subject_id
                        ORDER BY s.status, last_treatment DESC
                    """
                },
                {
                    "id": "available_subjects",
                    "title": "Available Subjects",
                    "description": "Lists subjects not currently assigned to any active study",
                    "sql": """
                        SELECT
                            s.lab_id,
                            sp.common_name as species,
                            s.sex,
                            s.birth_date
                        FROM subjects s
                        JOIN species sp ON s.species_id = sp.species_id
                        WHERE s.status = 'active'
                        AND NOT EXISTS (
                            SELECT 1 FROM subject_conditions sc
                            JOIN experimental_conditions ec ON sc.condition_id = ec.condition_id
                            JOIN studies st ON ec.study_id = st.study_id
                            WHERE sc.subject_id = s.subject_id
                            AND st.status = 'active'
                        )
                        ORDER BY s.lab_id
                    """
                },
                {
                    "id": "all_compounds",
                    "title": "List All Compounds",
                    "description": "Displays all compounds with their names and molecular formulas",
                    "sql": """
                        SELECT compound_name, molecular_formula
                        FROM compounds
                        ORDER BY compound_name
                    """
                },
                {
                    "id": "recent_studies",
                    "title": "Recent Studies",
                    "description": "Lists studies created or updated in the last 30 days",
                    "sql": """
                        SELECT study_code, title, status, created_at, updated_at
                        FROM studies
                        WHERE created_at >= date('now', '-30 days')
                           OR updated_at >= date('now', '-30 days')
                        ORDER BY updated_at DESC
                    """
                },
                {
                    "id": "species_summary",
                    "title": "Species Summary",
                    "description": "Counts the number of subjects per species",
                    "sql": """
                        SELECT sp.common_name, COUNT(s.subject_id) as subject_count
                        FROM species sp
                        LEFT JOIN subjects s ON sp.species_id = s.species_id
                        GROUP BY sp.species_id
                        ORDER BY subject_count DESC
                    """
                },
                {
                    "id": "inactive_subjects",
                    "title": "Inactive Subjects",
                    "description": "Lists all inactive subjects with their species",
                    "sql": """
                        SELECT s.lab_id, sp.common_name, s.sex, s.birth_date
                        FROM subjects s
                        JOIN species sp ON s.species_id = sp.species_id
                        WHERE s.status = 'inactive'
                        ORDER BY s.lab_id
                    """
                },
                {
                    "id": "compounds_by_formula",
                    "title": "Compounds by Molecular Formula",
                    "description": "Lists compounds matching a partial molecular formula",
                    "sql": """
                        SELECT compound_name, molecular_formula
                        FROM compounds
                        WHERE molecular_formula LIKE '%C%'
                        ORDER BY compound_name
                    """
                },
                {
                    "id": "compound_effectiveness_by_outcome",
                    "title": "Compound Effectiveness by Treatment Outcome",
                    "description": "Counts successful treatments and subjects per compound, indicating effectiveness based on treatment outcomes",
                    "sql": """
                        SELECT
                            c.compound_name,
                            COUNT(DISTINCT CASE WHEN sc.outcome = 'success' THEN sc.subject_id END) as successful_subjects,
                            COUNT(CASE WHEN sc.outcome = 'success' THEN sc.subject_condition_id END) as successful_treatments,
                            COUNT(DISTINCT sc.subject_id) as total_subjects_treated
                        FROM compounds c
                        LEFT JOIN dosage_definitions dd ON c.compound_id = dd.compound_id
                        LEFT JOIN subject_conditions sc ON dd.dosage_id = sc.dosage_id
                        GROUP BY c.compound_id, c.compound_name
                        ORDER BY successful_subjects DESC
                    """
                }
            ]

    @Slot(result=bool)
    def reloadCommands(self):
        """Reload commands from JSON file"""
        old_count = len(self._commands)
        self._commands.clear()
        self._load_commands()
        self.commandsChanged.emit()
        return len(self._commands) != old_count

    @Slot(QUrl, result=bool)
    def importCommands(self, file_url):
        """Import commands from JSON file at specified path"""
        try:
            file_path = Path(file_url.toLocalFile())
            with open(file_path, 'r', encoding='utf-8') as f:
                commands = json.load(f)

            # Save to default location
            with open("quick_commands.json", 'w', encoding='utf-8') as f:
                json.dump(commands, f, indent=2)

            return self.reloadCommands()
        except Exception as e:
            print(f"Error importing commands: {e}")
            return False

    @Property('QVariantList', notify=commandsChanged)
    def commands(self):
        return self._commands

    def get_command_by_id(self, cmd_id: str) -> QuickCommand:
        """Get a command by its ID"""
        for cmd in self._commands:
            if cmd.cmd_id == cmd_id:
                return cmd
        return None
