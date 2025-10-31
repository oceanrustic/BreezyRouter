/**
 * @description Lightning Web Component for managing member status in BreezyRouter
 * Provides quick status change interface with bulk operations and audit trail
 * @author BreezyRouter Team
 * @date 2025
 */
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRouterMembers from '@salesforce/apex/BreezyRouterController.getRouterMembers';
import updateMemberStatus from '@salesforce/apex/BreezyRouterController.updateMemberStatus';
import bulkUpdateMemberStatus from '@salesforce/apex/BreezyRouterController.bulkUpdateMemberStatus';
import getStatusHistory from '@salesforce/apex/BreezyRouterController.getStatusHistory';
import getMemberStatusCounts from '@salesforce/apex/BreezyRouterController.getMemberStatusCounts';

const STATUS_OPTIONS = [
    { label: 'Active', value: 'Active' },
    { label: 'PTO', value: 'PTO' },
    { label: 'On Leave', value: 'On Leave' },
    { label: 'Other', value: 'Other' }
];

const MEMBER_COLUMNS = [
    { 
        label: 'Member Name', 
        fieldName: 'userName', 
        type: 'text',
        sortable: true 
    },
    { 
        label: 'Email', 
        fieldName: 'userEmail', 
        type: 'email',
        sortable: true 
    },
    { 
        label: 'Department', 
        fieldName: 'department', 
        type: 'text',
        sortable: true 
    },
    { 
        label: 'Current Status', 
        fieldName: 'status', 
        type: 'text',
        cellAttributes: {
            class: { fieldName: 'statusClass' }
        }
    },
    { 
        label: 'Last Routed', 
        fieldName: 'routedDate', 
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        },
        sortable: true
    },
    { 
        label: 'Status Changed', 
        fieldName: 'statusChangedDate', 
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        },
        sortable: true
    }
];

export default class BreezyStatusManager extends LightningElement {
    @api routerId;
    @api routerName;
    
    @track members = [];
    @track selectedRows = [];
    @track statusCounts = {};
    @track showConfirmDialog = false;
    @track showHistoryModal = false;
    @track statusHistory = [];
    
    memberColumns = MEMBER_COLUMNS;
    statusOptions = STATUS_OPTIONS;
    
    bulkStatus = 'Active';
    bulkReason = '';
    searchTerm = '';
    sortedBy = 'userName';
    sortDirection = 'asc';
    
    wiredMembersResult;
    wiredStatusCountsResult;
    wiredHistoryResult;
    
    // Wire methods
    @wire(getRouterMembers, { routerId: '$routerId' })
    wiredMembers(result) {
        this.wiredMembersResult = result;
        if (result.data) {
            this.members = result.data.map(member => ({
                ...member,
                statusClass: this.getStatusClass(member.status)
            }));
        } else if (result.error) {
            this.showToast('Error', 'Error loading members: ' + result.error.body.message, 'error');
        }
    }
    
    @wire(getMemberStatusCounts, { routerId: '$routerId' })
    wiredStatusCounts(result) {
        this.wiredStatusCountsResult = result;
        if (result.data) {
            this.statusCounts = result.data;
        } else if (result.error) {
            this.showToast('Error', 'Error loading status counts: ' + result.error.body.message, 'error');
        }
    }
    
    // Computed properties
    get modalHeader() {
        return `Manage Status - ${this.routerName || 'Router'}`;
    }
    
    get hasSelectedMembers() {
        return this.selectedRows && this.selectedRows.length > 0;
    }
    
    get buttonsDisabled() {
        return !this.hasSelectedMembers;
    }
    
    get selectedCount() {
        return this.selectedRows ? this.selectedRows.length : 0;
    }
    
    get filteredMembers() {
        if (!this.searchTerm) {
            return this.members;
        }
        
        const term = this.searchTerm.toLowerCase();
        return this.members.filter(member => 
            member.userName?.toLowerCase().includes(term) ||
            member.userEmail?.toLowerCase().includes(term) ||
            member.department?.toLowerCase().includes(term)
        );
    }
    
    get activeCount() {
        return this.statusCounts.Active || 0;
    }
    
    get ptoCount() {
        return this.statusCounts.PTO || 0;
    }
    
    get onLeaveCount() {
        return this.statusCounts['On Leave'] || 0;
    }
    
    get otherCount() {
        return this.statusCounts.Other || 0;
    }
    
    get hasStatusHistory() {
        return this.statusHistory && this.statusHistory.length > 0;
    }
    
    // Event handlers
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }
    
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows.map(row => row.id);
    }
    
    handleClearSelection() {
        this.selectedRows = [];
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.showToast('Info', 'Selection cleared. You can now select different members.', 'info');
    }
    
    handleBulkStatusChange(event) {
        this.bulkStatus = event.target.value;
    }
    
    handleBulkReasonChange(event) {
        this.bulkReason = event.target.value;
    }
    
    handleQuickStatusChange(event) {
        const status = event.target.dataset.status;
        if (!this.hasSelectedMembers) {
            this.showToast('Warning', 'Please select members to update', 'warning');
            return;
        }
        
        this.bulkStatus = status;
        this.showConfirmDialog = true;
    }
    
    handleBulkUpdate() {
        if (!this.hasSelectedMembers) {
            this.showToast('Warning', 'Please select members to update', 'warning');
            return;
        }
        
        this.showConfirmDialog = true;
    }
    
    handleConfirmStatusChange() {
        this.showConfirmDialog = false;
        this.performBulkUpdate();
    }
    
    handleCancelStatusChange() {
        this.showConfirmDialog = false;
    }
    
    performBulkUpdate() {
        bulkUpdateMemberStatus({
            memberIds: this.selectedRows,
            newStatus: this.bulkStatus,
            reason: this.bulkReason
        })
        .then(count => {
            this.showToast('Success', `Updated status for ${count} member(s) to ${this.bulkStatus}. Selection cleared - you can now select different members.`, 'success');
            this.bulkReason = '';
            this.selectedRows = [];
            
            // Clear the data table selection
            this.template.querySelector('lightning-datatable').selectedRows = [];
            
            // Refresh all data
            return Promise.all([
                refreshApex(this.wiredMembersResult),
                refreshApex(this.wiredStatusCountsResult)
            ]);
        })
        .catch(error => {
            this.showToast('Error', 'Error updating status: ' + error.body.message, 'error');
        });
    }
    
    handleViewHistory() {
        this.showHistoryModal = true;
        this.loadStatusHistory();
    }
    
    handleCloseHistory() {
        this.showHistoryModal = false;
    }
    
    loadStatusHistory() {
        getStatusHistory({ routerId: this.routerId })
            .then(data => {
                this.statusHistory = data;
            })
            .catch(error => {
                this.showToast('Error', 'Error loading history: ' + error.body.message, 'error');
            });
    }
    
    handleClose() {
        // Dispatch event to parent component
        this.dispatchEvent(new CustomEvent('close', {
            detail: { refreshNeeded: true }
        }));
    }
    
    // Helper methods
    getStatusClass(status) {
        switch(status) {
            case 'Active':
                return 'slds-text-color_success slds-text-title_bold';
            case 'PTO':
                return 'slds-text-color_default';
            case 'On Leave':
                return 'slds-text-color_weak';
            case 'Other':
                return 'slds-text-color_default';
            default:
                return '';
        }
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}

