import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRouters from '@salesforce/apex/BreezyRouterController.getRouters';
import searchRouters from '@salesforce/apex/BreezyRouterController.searchRouters';
import createRouter from '@salesforce/apex/BreezyRouterController.createRouter';
import updateRouter from '@salesforce/apex/BreezyRouterController.updateRouter';
import deleteRouter from '@salesforce/apex/BreezyRouterController.deleteRouter';

export default class BreezyRouterManagement extends LightningElement {
    @track routers = [];
    @track filteredRouters = [];
    @track isLoading = false;
    @track showModal = false;
    @track showDeleteModal = false;
    @track searchTerm = '';
    
    // Modal state
    @track modalTitle = '';
    @track modalMode = ''; // 'create' or 'edit'
    @track selectedRouterId = '';
    @track routerName = '';
    @track routerDescription = '';
    
    // Delete modal state
    @track deleteRouterId = '';
    @track deleteRouterName = '';
    @track deleteMembers = false;
    
    // User assignment modal state
    @track showUserAssignmentModal = false;
    @track showUserAssignmentComponent = true; // Toggle to recreate component
    @track userAssignmentRouterId = '';
    @track userAssignmentRouterName = '';
    
    // Status management modal state
    @track showStatusManagerModal = false;
    @track showStatusManagerComponent = true; // Toggle to recreate component
    @track statusManagerRouterId = '';
    @track statusManagerRouterName = '';
    
    // Tab management state
    @track selectedTab = 'routers'; // 'routers' or 'dashboard'
    
    // Wire result for refresh
    wiredRoutersResult;
    
    // Data table columns
    columns = [
        { 
            label: 'Router Name', 
            fieldName: 'name', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'Description', 
            fieldName: 'description', 
            type: 'text',
            wrapText: true
        },
        { 
            label: 'Total Members', 
            fieldName: 'totalMembers', 
            type: 'number',
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Active Members', 
            fieldName: 'activeMembers', 
            type: 'number',
            cellAttributes: { alignment: 'center' }
        },
        {
            label: 'Last Modified',
            fieldName: 'lastModifiedDate',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            }
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Manage Users', name: 'manage_users', iconName: 'utility:people' },
                    { label: 'Manage Status', name: 'manage_status', iconName: 'utility:shield' },
                    { label: 'Edit', name: 'edit', iconName: 'utility:edit' },
                    { label: 'View Details', name: 'view', iconName: 'utility:preview' },
                    { label: 'Delete', name: 'delete', iconName: 'utility:delete' }
                ]
            }
        }
    ];
    
    @wire(getRouters)
    wiredRouters(result) {
        this.wiredRoutersResult = result;
        if (result.data) {
            this.routers = result.data;
            this.filteredRouters = result.data;
            this.isLoading = false;
        } else if (result.error) {
            this.showToast('Error', 'Error loading routers: ' + result.error.body.message, 'error');
            this.isLoading = false;
        }
    }
    
    get hasRouters() {
        return this.filteredRouters && this.filteredRouters.length > 0;
    }
    
    // Search handler
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.performSearch();
    }
    
    performSearch() {
        if (this.searchTerm) {
            this.isLoading = true;
            searchRouters({ searchTerm: this.searchTerm })
                .then(result => {
                    this.filteredRouters = result;
                    this.isLoading = false;
                })
                .catch(error => {
                    this.showToast('Error', 'Error searching routers: ' + error.body.message, 'error');
                    this.isLoading = false;
                });
        } else {
            this.filteredRouters = this.routers;
        }
    }
    
    // Create new router button handler
    handleCreateRouter() {
        this.modalMode = 'create';
        this.modalTitle = 'Create New Router';
        this.selectedRouterId = '';
        this.routerName = '';
        this.routerDescription = '';
        this.showModal = true;
    }
    
    // Row action handler
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        switch (action.name) {
            case 'manage_users':
                this.handleManageUsers(row);
                break;
            case 'manage_status':
                this.handleManageStatus(row);
                break;
            case 'edit':
                this.handleEditRouter(row);
                break;
            case 'view':
                this.handleViewRouter(row);
                break;
            case 'delete':
                this.handleDeleteRouter(row);
                break;
        }
    }
    
    // Manage users for router
    handleManageUsers(router) {
        this.userAssignmentRouterId = router.id;
        this.userAssignmentRouterName = router.name;
        
        // Force component recreation by toggling
        this.showUserAssignmentComponent = false;
        setTimeout(() => {
            this.showUserAssignmentComponent = true;
            this.showUserAssignmentModal = true;
        }, 0);
    }
    
    // Edit router
    handleEditRouter(router) {
        this.modalMode = 'edit';
        this.modalTitle = 'Edit Router';
        this.selectedRouterId = router.id;
        this.routerName = router.name;
        this.routerDescription = router.description || '';
        this.showModal = true;
    }
    
    // View router (navigate to detail view - to be implemented)
    handleViewRouter(router) {
        // TODO: Navigate to router detail page
        this.showToast('Info', 'Router details view coming soon!', 'info');
    }
    
    // Delete router
    handleDeleteRouter(router) {
        this.deleteRouterId = router.id;
        this.deleteRouterName = router.name;
        this.deleteMembers = false;
        this.showDeleteModal = true;
    }
    
    // Modal input handlers
    handleNameChange(event) {
        this.routerName = event.target.value;
    }
    
    handleDescriptionChange(event) {
        this.routerDescription = event.target.value;
    }
    
    // Save router (create or update)
    handleSaveRouter() {
        // Validation
        if (!this.routerName || this.routerName.trim() === '') {
            this.showToast('Error', 'Please enter a router name', 'error');
            return;
        }
        
        this.isLoading = true;
        
        if (this.modalMode === 'create') {
            // Create new router
            createRouter({ 
                name: this.routerName.trim(), 
                description: this.routerDescription.trim() 
            })
                .then(() => {
                    this.showToast('Success', 'Router created successfully', 'success');
                    this.closeModal();
                    return refreshApex(this.wiredRoutersResult);
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                    this.isLoading = false;
                });
        } else {
            // Update existing router
            updateRouter({ 
                routerId: this.selectedRouterId,
                name: this.routerName.trim(), 
                description: this.routerDescription.trim() 
            })
                .then(() => {
                    this.showToast('Success', 'Router updated successfully', 'success');
                    this.closeModal();
                    return refreshApex(this.wiredRoutersResult);
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                    this.isLoading = false;
                });
        }
    }
    
    // Close modal
    closeModal() {
        this.showModal = false;
        this.modalMode = '';
        this.selectedRouterId = '';
        this.routerName = '';
        this.routerDescription = '';
        this.isLoading = false;
    }
    
    // Delete modal handlers
    handleDeleteMembersChange(event) {
        this.deleteMembers = event.target.checked;
    }
    
    handleConfirmDelete() {
        this.isLoading = true;
        
        deleteRouter({ 
            routerId: this.deleteRouterId, 
            deleteMembers: this.deleteMembers 
        })
            .then(() => {
                this.showToast('Success', 'Router deleted successfully', 'success');
                this.closeDeleteModal();
                return refreshApex(this.wiredRoutersResult);
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
                this.isLoading = false;
            });
    }
    
    closeDeleteModal() {
        this.showDeleteModal = false;
        this.deleteRouterId = '';
        this.deleteRouterName = '';
        this.deleteMembers = false;
        this.isLoading = false;
    }
    
    // User assignment modal handlers
    closeUserAssignmentModal() {
        this.showUserAssignmentModal = false;
        this.showUserAssignmentComponent = false; // Destroy component
        this.userAssignmentRouterId = '';
        this.userAssignmentRouterName = '';
        // Refresh router data to show updated member counts
        return refreshApex(this.wiredRoutersResult);
    }
    
    handleUsersAdded(event) {
        // Toast is already shown by child component - no need to duplicate
        // Just silently acknowledge the event
        // Refresh will happen when modal closes
    }
    
    handleUsersRemoved(event) {
        // Toast is already shown by child component - no need to duplicate
        // Just silently acknowledge the event
        // Refresh will happen when modal closes
    }
    
    // Status management modal handlers
    handleManageStatus(router) {
        this.statusManagerRouterId = router.id;
        this.statusManagerRouterName = router.name;
        
        // Force component recreation by toggling
        this.showStatusManagerComponent = false;
        setTimeout(() => {
            this.showStatusManagerComponent = true;
            this.showStatusManagerModal = true;
        }, 0);
    }
    
    closeStatusManagerModal() {
        this.showStatusManagerModal = false;
        this.showStatusManagerComponent = false; // Destroy component
        this.statusManagerRouterId = '';
        this.statusManagerRouterName = '';
        // Refresh router data to show updated member counts
        return refreshApex(this.wiredRoutersResult);
    }
    
    handleStatusUpdated(event) {
        // Toast is already shown by child component
        // Refresh will happen when modal closes
    }
    
    // Tab handlers
    handleTabChange(event) {
        const tabName = event.currentTarget.dataset.tab;
        this.selectedTab = tabName;
        
        // Refresh dashboard data when switching to dashboard tab
        if (tabName === 'dashboard') {
            // Dispatch custom event to refresh dashboard
            const refreshEvent = new CustomEvent('refreshdashboard', {
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(refreshEvent);
        }
    }
    
    get isRoutersTabSelected() {
        return this.selectedTab === 'routers';
    }
    
    get isDashboardTabSelected() {
        return this.selectedTab === 'dashboard';
    }
    
    get routerTabClass() {
        return this.isRoutersTabSelected ? 'slds-tabs_default__link slds-is-active' : 'slds-tabs_default__link';
    }
    
    get dashboardTabClass() {
        return this.isDashboardTabSelected ? 'slds-tabs_default__link slds-is-active' : 'slds-tabs_default__link';
    }
    
    // Utility: Show toast message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}

