import { LightningElement, wire, track, api } from 'lwc';
import getTeamAbsences from '@salesforce/apex/AbsenceController.getTeamAbsences';
import deleteAbsenceApex from '@salesforce/apex/AbsenceController.deleteAbsence';
import { refreshApex } from '@salesforce/apex';

const COLUMNS = [
  { label: 'Name', fieldName: 'Name' },
  { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date' },
  { label: 'End Date', fieldName: 'End_Date__c', type: 'date' },
  { label: 'Is Returned?', fieldName: 'Is_Returned__c' },
  { label: 'Team Member', fieldName: 'Team_Member__r.Name' },
  {
    type: 'action',
    typeAttributes: { rowActions: [
      { label: 'Edit', name: 'edit' },
      { label: 'Exclude', name: 'delete' }
    ] }
  }
];

export default class AbsenceManager extends LightningElement {
  @track absences = [];
  columns = COLUMNS;
  isModalOpen = false;
  @api recordId;
  absenceId = null;
  modalTitle = '';
  isLoading = true;
  isEditing = false;
  wiredAbsencesResult;
  formError = '';

  @wire(getTeamAbsences, { teamId: '$recordId' })
  wiredAbsences(result) {
    this.wiredAbsencesResult = result;
    const { error, data } = result;
    this.isLoading = false;
    if (data) {
      this.absences = Array.isArray(data) ? data : [];
    } else if (error) {
      this.absences = [];
      console.error('Error fetching absences:', error);
    }
  }

  get hasAbsences() {
    return this.absences && this.absences.length > 0;
  }

  get showNoAbsencesMessage() {
    return !this.isLoading && (!this.absences || this.absences.length === 0);
  }

  handleNew() {
    this.isEditing = false;
    this.absenceId = null;
    this.modalTitle = 'New Absence';
    this.isModalOpen = true;
    this.formError = '';
  }

  handleRowAction(event) {
    const action = event.detail.action.name;
    const row = event.detail.row;
    if (action === 'edit') {
      this.absenceId = row.Id;
      this.modalTitle = 'Edit Absence';
      this.isModalOpen = true;
      this.isEditing = true;
      this.formError = '';
    } else if (action === 'delete') {
      this.deleteAbsence(row.Id);
    }
  }

  closeModal() {
    this.isModalOpen = false;
    this.isEditing = false;
    this.absenceId = null;
    this.formError = '';
  }

  async handleSuccess() {
    this.isModalOpen = false;
    this.isEditing = false;
    this.absenceId = null;
    await refreshApex(this.wiredAbsencesResult);
  }

  handleFormError(event) {
    this.formError = 'There was an error saving the absence.';
    // Optionally, you can show a toast here
    // eslint-disable-next-line no-console
    console.error('Form error:', event.detail);
  }

  async deleteAbsence(absenceId) {
    try {
      await deleteAbsenceApex({ absenceId });
      await refreshApex(this.wiredAbsencesResult);
    } catch (error) {
      this.formError = 'Error deleting absence.';
      // eslint-disable-next-line no-console
      console.error('Error deleting absence:', error);
    }
  }
}
