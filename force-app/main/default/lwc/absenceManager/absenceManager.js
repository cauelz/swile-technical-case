import { LightningElement, wire, track, api } from 'lwc';
import getTeamAbsences from '@salesforce/apex/AbsenceController.getTeamAbsences';

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
  @track absences = null;
  columns = COLUMNS;
  isModalOpen = false;
  @api recordId;
  absenceId;
  modalTitle = '';
  isLoading = true;
  isEditing = false; 

  @wire(getTeamAbsences, { teamId: '$recordId' })
  wiredAbsences({ error, data }) {
    if (data) {
        
        if(data.length !== 0) {
            this.absences = data;
        }

        this.isLoading = false;
    } else if (error) {
        this.absences = null;
        this.isLoading = false;
        console.error('Error fetching absences:', error);
    }
  }

  handleNew() {
    this.isEditing = false;
    this.absenceId = null;
    this.modalTitle = 'New Absence';
    this.isModalOpen = true;
  }

  handleRowAction(event) {
    const action = event.detail.action.name;
    const row = event.detail.row;
    if (action === 'edit') {
      this.absenceId = row.Id;
      this.modalTitle = 'Edit Absence';
      this.isModalOpen = true;
      this.isEditing = true;
    } else if (action === 'delete') {
      this.deleteAbsence(row.Id);
    }
  }

  closeModal() {
    this.isModalOpen = false;
    this.isEditing   = false;
    this.absenceId   = null;
  }

  handleSuccess() {
    this.isModalOpen = false;
    return refreshApex(this.wiredAbsences);
  }
}
