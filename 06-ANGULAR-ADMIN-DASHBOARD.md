# 🖥️ معماری داشبورد مدیریتی Angular - Hivork Admin Panel

## 🏗️ نمای کلی معماری

### Technology Stack
```
Framework: Angular 17+
Language: TypeScript 5.3+
State Management: NgRx 17+
UI Library: Angular Material 17+ / PrimeNG 17+
Styling: SCSS + Tailwind CSS
HTTP Client: Angular HttpClient
Charts: Chart.js / ApexCharts
Tables: AG-Grid
Forms: Reactive Forms
Authentication: JWT + Guards
```

### معماری: Modular Architecture + Feature Modules

```
hivork-admin/
├── angular.json
├── tsconfig.json
├── package.json
├── tailwind.config.js
├── .eslintrc.json
│
├── src/
│   ├── main.ts
│   ├── index.html
│   ├── styles.scss
│   │
│   ├── app/
│   │   ├── app.component.ts
│   │   ├── app.component.html
│   │   ├── app.component.scss
│   │   ├── app.config.ts
│   │   ├── app.routes.ts
│   │   │
│   │   ├── core/                      # هسته اپلیکیشن
│   │   │   ├── guards/               # محافظ‌های مسیر
│   │   │   │   ├── auth.guard.ts
│   │   │   │   ├── role.guard.ts
│   │   │   │   └── permission.guard.ts
│   │   │   ├── interceptors/         # اینترسپتورها
│   │   │   │   ├── auth.interceptor.ts
│   │   │   │   ├── error.interceptor.ts
│   │   │   │   ├── loading.interceptor.ts
│   │   │   │   └── cache.interceptor.ts
│   │   │   ├── services/             # سرویس‌های اصلی
│   │   │   │   ├── api.service.ts
│   │   │   │   ├── auth.service.ts
│   │   │   │   ├── storage.service.ts
│   │   │   │   ├── notification.service.ts
│   │   │   │   ├── logger.service.ts
│   │   │   │   └── export.service.ts
│   │   │   ├── models/               # مدل‌های مشترک
│   │   │   │   ├── user.model.ts
│   │   │   │   ├── api-response.model.ts
│   │   │   │   └── pagination.model.ts
│   │   │   ├── constants/            # ثابت‌ها
│   │   │   │   ├── api.constants.ts
│   │   │   │   ├── app.constants.ts
│   │   │   │   └── route.constants.ts
│   │   │   └── utils/                # ابزارهای کمکی
│   │   │       ├── validators.ts
│   │   │       ├── formatters.ts
│   │   │       ├── helpers.ts
│   │   │       └── date.utils.ts
│   │   │
│   │   ├── shared/                    # ماژول‌های مشترک
│   │   │   ├── components/           # کامپوننت‌های مشترک
│   │   │   │   ├── layout/
│   │   │   │   │   ├── sidebar/
│   │   │   │   │   │   ├── sidebar.component.ts
│   │   │   │   │   │   ├── sidebar.component.html
│   │   │   │   │   │   └── sidebar.component.scss
│   │   │   │   │   ├── header/
│   │   │   │   │   │   ├── header.component.ts
│   │   │   │   │   │   ├── header.component.html
│   │   │   │   │   │   └── header.component.scss
│   │   │   │   │   ├── footer/
│   │   │   │   │   │   └── footer.component.ts
│   │   │   │   │   └── breadcrumb/
│   │   │   │   │       └── breadcrumb.component.ts
│   │   │   │   ├── tables/
│   │   │   │   │   ├── data-table/
│   │   │   │   │   │   ├── data-table.component.ts
│   │   │   │   │   │   ├── data-table.component.html
│   │   │   │   │   │   └── data-table.component.scss
│   │   │   │   │   └── pagination/
│   │   │   │   │       └── pagination.component.ts
│   │   │   │   ├── forms/
│   │   │   │   │   ├── form-input/
│   │   │   │   │   ├── form-select/
│   │   │   │   │   ├── form-textarea/
│   │   │   │   │   ├── form-datepicker/
│   │   │   │   │   └── form-upload/
│   │   │   │   ├── cards/
│   │   │   │   │   ├── stat-card/
│   │   │   │   │   ├── chart-card/
│   │   │   │   │   └── info-card/
│   │   │   │   ├── modals/
│   │   │   │   │   ├── confirmation-modal/
│   │   │   │   │   └── form-modal/
│   │   │   │   ├── loaders/
│   │   │   │   │   ├── spinner/
│   │   │   │   │   └── skeleton/
│   │   │   │   └── misc/
│   │   │   │       ├── empty-state/
│   │   │   │       ├── error-state/
│   │   │   │       └── alert/
│   │   │   ├── directives/           # دایرکتیوها
│   │   │   │   ├── permission.directive.ts
│   │   │   │   ├── tooltip.directive.ts
│   │   │   │   └── click-outside.directive.ts
│   │   │   ├── pipes/                # پایپ‌ها
│   │   │   │   ├── persian-date.pipe.ts
│   │   │   │   ├── currency.pipe.ts
│   │   │   │   ├── truncate.pipe.ts
│   │   │   │   └── safe-html.pipe.ts
│   │   │   └── shared.module.ts
│   │   │
│   │   ├── features/                  # ماژول‌های اصلی
│   │   │   │
│   │   │   ├── auth/                 # 🔐 احراز هویت
│   │   │   │   ├── pages/
│   │   │   │   │   ├── login/
│   │   │   │   │   │   ├── login.component.ts
│   │   │   │   │   │   ├── login.component.html
│   │   │   │   │   │   └── login.component.scss
│   │   │   │   │   ├── forgot-password/
│   │   │   │   │   └── reset-password/
│   │   │   │   ├── services/
│   │   │   │   │   └── auth.service.ts
│   │   │   │   ├── store/
│   │   │   │   │   ├── auth.actions.ts
│   │   │   │   │   ├── auth.reducer.ts
│   │   │   │   │   ├── auth.selectors.ts
│   │   │   │   │   └── auth.effects.ts
│   │   │   │   └── auth.routes.ts
│   │   │   │
│   │   │   ├── dashboard/            # 📊 داشبورد اصلی
│   │   │   │   ├── pages/
│   │   │   │   │   └── overview/
│   │   │   │   │       ├── overview.component.ts
│   │   │   │   │       ├── overview.component.html
│   │   │   │   │       └── overview.component.scss
│   │   │   │   ├── components/
│   │   │   │   │   ├── stats-cards/
│   │   │   │   │   ├── sales-chart/
│   │   │   │   │   ├── recent-orders/
│   │   │   │   │   ├── top-products/
│   │   │   │   │   └── recent-customers/
│   │   │   │   ├── services/
│   │   │   │   │   └── dashboard.service.ts
│   │   │   │   ├── store/
│   │   │   │   └── dashboard.routes.ts
│   │   │   │
│   │   │   ├── users/                # 👥 مدیریت کاربران سیستم
│   │   │   │   ├── pages/
│   │   │   │   │   ├── user-list/
│   │   │   │   │   │   ├── user-list.component.ts
│   │   │   │   │   │   ├── user-list.component.html
│   │   │   │   │   │   └── user-list.component.scss
│   │   │   │   │   ├── user-detail/
│   │   │   │   │   ├── user-form/
│   │   │   │   │   └── user-permissions/
│   │   │   │   ├── components/
│   │   │   │   │   ├── user-card/
│   │   │   │   │   └── user-table/
│   │   │   │   ├── services/
│   │   │   │   │   └── user.service.ts
│   │   │   │   ├── models/
│   │   │   │   │   └── user.model.ts
│   │   │   │   ├── store/
│   │   │   │   └── users.routes.ts
│   │   │   │
│   │   │   ├── businesses/           # 🏢 مدیریت کسب‌وکارها
│   │   │   │   ├── pages/
│   │   │   │   │   ├── business-list/
│   │   │   │   │   ├── business-detail/
│   │   │   │   │   ├── business-analytics/
│   │   │   │   │   └── business-settings/
│   │   │   │   ├── components/
│   │   │   │   │   ├── business-card/
│   │   │   │   │   ├── business-stats/
│   │   │   │   │   └── business-activity-log/
│   │   │   │   ├── services/
│   │   │   │   │   └── business.service.ts
│   │   │   │   ├── models/
│   │   │   │   ├── store/
│   │   │   │   └── businesses.routes.ts
│   │   │   │
│   │   │   ├── subscriptions/        # 💳 مدیریت اشتراک‌ها
│   │   │   │   ├── pages/
│   │   │   │   │   ├── subscription-list/
│   │   │   │   │   ├── subscription-detail/
│   │   │   │   │   ├── plans-management/
│   │   │   │   │   └── payment-history/
│   │   │   │   ├── components/
│   │   │   │   │   ├── plan-card/
│   │   │   │   │   ├── subscription-status/
│   │   │   │   │   └── payment-table/
│   │   │   │   ├── services/
│   │   │   │   │   └── subscription.service.ts
│   │   │   │   └── subscriptions.routes.ts
│   │   │   │
│   │   │   ├── support/              # 🎧 پشتیبانی
│   │   │   │   ├── pages/
│   │   │   │   │   ├── ticket-list/
│   │   │   │   │   ├── ticket-detail/
│   │   │   │   │   └── ticket-create/
│   │   │   │   ├── components/
│   │   │   │   │   ├── ticket-card/
│   │   │   │   │   ├── ticket-timeline/
│   │   │   │   │   └── ticket-reply-form/
│   │   │   │   ├── services/
│   │   │   │   │   └── support.service.ts
│   │   │   │   └── support.routes.ts
│   │   │   │
│   │   │   ├── analytics/            # 📈 آنالیتیکس پلتفرم
│   │   │   │   ├── pages/
│   │   │   │   │   ├── platform-analytics/
│   │   │   │   │   ├── revenue-report/
│   │   │   │   │   ├── user-behavior/
│   │   │   │   │   └── business-insights/
│   │   │   │   ├── components/
│   │   │   │   │   ├── analytics-chart/
│   │   │   │   │   ├── metrics-card/
│   │   │   │   │   └── report-filter/
│   │   │   │   ├── services/
│   │   │   │   │   └── analytics.service.ts
│   │   │   │   └── analytics.routes.ts
│   │   │   │
│   │   │   ├── system/               # ⚙️ تنظیمات سیستم
│   │   │   │   ├── pages/
│   │   │   │   │   ├── settings/
│   │   │   │   │   ├── business-categories/
│   │   │   │   │   ├── email-templates/
│   │   │   │   │   ├── sms-templates/
│   │   │   │   │   └── audit-logs/
│   │   │   │   ├── components/
│   │   │   │   │   ├── settings-form/
│   │   │   │   │   └── log-viewer/
│   │   │   │   ├── services/
│   │   │   │   │   └── system.service.ts
│   │   │   │   └── system.routes.ts
│   │   │   │
│   │   │   ├── notifications/        # 🔔 مدیریت نوتیفیکیشن‌ها
│   │   │   │   ├── pages/
│   │   │   │   │   ├── notification-list/
│   │   │   │   │   └── send-notification/
│   │   │   │   ├── components/
│   │   │   │   │   └── notification-item/
│   │   │   │   ├── services/
│   │   │   │   │   └── notification.service.ts
│   │   │   │   └── notifications.routes.ts
│   │   │   │
│   │   │   └── reports/              # 📊 گزارش‌های سیستم
│   │   │       ├── pages/
│   │   │       │   ├── financial-report/
│   │   │       │   ├── user-activity/
│   │   │       │   └── business-performance/
│   │   │       ├── components/
│   │   │       │   └── report-viewer/
│   │   │       ├── services/
│   │   │       │   └── report.service.ts
│   │   │       └── reports.routes.ts
│   │   │
│   │   └── store/                     # NgRx Store (Global)
│   │       ├── app.state.ts
│   │       ├── app.reducer.ts
│   │       ├── app.selectors.ts
│   │       └── index.ts
│   │
│   ├── assets/                        # منابع استاتیک
│   │   ├── images/
│   │   ├── icons/
│   │   ├── fonts/
│   │   └── i18n/
│   │       ├── fa.json
│   │       └── en.json
│   │
│   └── environments/                  # محیط‌ها
│       ├── environment.ts
│       └── environment.prod.ts
│
└── tests/                             # تست‌ها
    ├── unit/
    └── e2e/
```

---

## 📦 package.json

```json
{
  "name": "hivork-admin",
  "version": "1.0.0",
  "scripts": {
    "start": "ng serve",
    "build": "ng build",
    "build:prod": "ng build --configuration production",
    "test": "ng test",
    "lint": "ng lint",
    "e2e": "ng e2e"
  },
  "dependencies": {
    "@angular/animations": "^17.0.0",
    "@angular/common": "^17.0.0",
    "@angular/compiler": "^17.0.0",
    "@angular/core": "^17.0.0",
    "@angular/forms": "^17.0.0",
    "@angular/platform-browser": "^17.0.0",
    "@angular/platform-browser-dynamic": "^17.0.0",
    "@angular/router": "^17.0.0",
    "@angular/material": "^17.0.0",
    "@angular/cdk": "^17.0.0",
    "@ngrx/store": "^17.0.0",
    "@ngrx/effects": "^17.0.0",
    "@ngrx/store-devtools": "^17.0.0",
    "primeng": "^17.0.0",
    "primeicons": "^7.0.0",
    "chart.js": "^4.4.0",
    "ng2-charts": "^5.0.0",
    "apexcharts": "^3.45.0",
    "ng-apexcharts": "^1.9.0",
    "ag-grid-angular": "^31.0.0",
    "ag-grid-community": "^31.0.0",
    "ngx-pagination": "^6.0.3",
    "ngx-toastr": "^18.0.0",
    "moment-jalaali": "^0.10.0",
    "rxjs": "^7.8.1",
    "tslib": "^2.6.2",
    "zone.js": "^0.14.2"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "^17.0.0",
    "@angular/cli": "^17.0.0",
    "@angular/compiler-cli": "^17.0.0",
    "@types/node": "^20.10.0",
    "typescript": "~5.3.0",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32"
  }
}
```

---

## 🎨 Styling & Theme

### styles.scss

```scss
@use '@angular/material' as mat;

// Import Tailwind
@tailwind base;
@tailwind components;
@tailwind utilities;

// Custom Theme Colors
$primary-palette: mat.define-palette(mat.$indigo-palette);
$accent-palette: mat.define-palette(mat.$teal-palette);
$warn-palette: mat.define-palette(mat.$red-palette);

$theme: mat.define-light-theme((
  color: (
    primary: $primary-palette,
    accent: $accent-palette,
    warn: $warn-palette,
  ),
  typography: mat.define-typography-config(),
  density: 0,
));

@include mat.all-component-themes($theme);

// RTL Support
[dir="rtl"] {
  direction: rtl;
  text-align: right;
}

// Custom Styles
:root {
  --primary-color: #6C5CE7;
  --secondary-color: #00B894;
  --success-color: #00B894;
  --danger-color: #FF7675;
  --warning-color: #FDCB6E;
  --info-color: #74B9FF;
  --dark-color: #2D3436;
  --light-color: #F5F6FA;
}

body {
  font-family: 'Vazir', 'Roboto', sans-serif;
  background-color: var(--light-color);
  direction: rtl;
}
```

---

## 🔐 Authentication

### auth.guard.ts

```typescript
import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  if (authService.isAuthenticated()) {
    return true;
  }
  
  router.navigate(['/auth/login'], {
    queryParams: { returnUrl: state.url }
  });
  return false;
};

export const roleGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  const requiredRoles = route.data['roles'] as string[];
  const userRole = authService.getUserRole();
  
  if (requiredRoles.includes(userRole)) {
    return true;
  }
  
  router.navigate(['/unauthorized']);
  return false;
};
```

### auth.interceptor.ts

```typescript
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';
import { catchError, throwError } from 'rxjs';
import { Router } from '@angular/router';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  const token = authService.getToken();
  
  if (token) {
    req = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
  }
  
  return next(req).pipe(
    catchError(error => {
      if (error.status === 401) {
        authService.logout();
        router.navigate(['/auth/login']);
      }
      return throwError(() => error);
    })
  );
};
```

---

## 📊 Dashboard Component Example

### overview.component.ts

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DashboardService } from '../../services/dashboard.service';
import { Observable } from 'rxjs';
import { DashboardStats } from '../../models/dashboard.model';

@Component({
  selector: 'app-overview',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './overview.component.html',
  styleUrl: './overview.component.scss'
})
export class OverviewComponent implements OnInit {
  stats$!: Observable<DashboardStats>;
  dateRange = 'this_month';
  
  constructor(private dashboardService: DashboardService) {}
  
  ngOnInit(): void {
    this.loadDashboardData();
  }
  
  loadDashboardData(): void {
    this.stats$ = this.dashboardService.getDashboardStats(this.dateRange);
  }
  
  onDateRangeChange(range: string): void {
    this.dateRange = range;
    this.loadDashboardData();
  }
}
```

### overview.component.html

```html
<div class="dashboard-container p-6">
  <div class="flex justify-between items-center mb-6">
    <h1 class="text-3xl font-bold text-gray-800">داشبورد مدیریت</h1>
    
    <div class="flex gap-4">
      <select 
        class="px-4 py-2 border rounded-lg"
        [(ngModel)]="dateRange"
        (change)="onDateRangeChange(dateRange)">
        <option value="today">امروز</option>
        <option value="this_week">این هفته</option>
        <option value="this_month" selected>این ماه</option>
        <option value="this_year">امسال</option>
      </select>
      
      <button class="btn btn-primary">
        <i class="pi pi-download"></i>
        دانلود گزارش
      </button>
    </div>
  </div>
  
  <!-- Stats Cards -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
    <ng-container *ngIf="stats$ | async as stats">
      <app-stat-card
        title="کل درآمد"
        [value]="stats.totalRevenue"
        type="currency"
        [change]="stats.revenueChange"
        icon="pi-dollar"
        color="success">
      </app-stat-card>
      
      <app-stat-card
        title="کسب‌وکارهای فعال"
        [value]="stats.activeBusinesses"
        type="number"
        [change]="stats.businessesChange"
        icon="pi-briefcase"
        color="primary">
      </app-stat-card>
      
      <app-stat-card
        title="کاربران جدید"
        [value]="stats.newUsers"
        type="number"
        [change]="stats.usersChange"
        icon="pi-users"
        color="info">
      </app-stat-card>
      
      <app-stat-card
        title="تیکت‌های باز"
        [value]="stats.openTickets"
        type="number"
        icon="pi-ticket"
        color="warning">
      </app-stat-card>
    </ng-container>
  </div>
  
  <!-- Charts -->
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
    <app-chart-card
      title="روند درآمد"
      [data]="(stats$ | async)?.revenueChart"
      type="line">
    </app-chart-card>
    
    <app-chart-card
      title="توزیع پلن‌های اشتراک"
      [data]="(stats$ | async)?.subscriptionDistribution"
      type="pie">
    </app-chart-card>
  </div>
  
  <!-- Tables -->
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <app-recent-businesses
      [businesses]="(stats$ | async)?.recentBusinesses">
    </app-recent-businesses>
    
    <app-recent-tickets
      [tickets]="(stats$ | async)?.recentTickets">
    </app-recent-tickets>
  </div>
</div>
```

---

## 📋 Data Table Component

### data-table.component.ts

```typescript
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface TableColumn {
  field: string;
  header: string;
  sortable?: boolean;
  filterable?: boolean;
  width?: string;
  type?: 'text' | 'number' | 'date' | 'badge' | 'actions';
}

@Component({
  selector: 'app-data-table',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './data-table.component.html'
})
export class DataTableComponent {
  @Input() data: any[] = [];
  @Input() columns: TableColumn[] = [];
  @Input() loading = false;
  @Input() totalRecords = 0;
  @Input() rowsPerPage = 10;
  
  @Output() pageChange = new EventEmitter<number>();
  @Output() sortChange = new EventEmitter<{field: string, order: 'asc'|'desc'}>();
  @Output() rowClick = new EventEmitter<any>();
  
  currentPage = 1;
  sortField?: string;
  sortOrder: 'asc' | 'desc' = 'asc';
  
  onSort(field: string): void {
    if (this.sortField === field) {
      this.sortOrder = this.sortOrder === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortField = field;
      this.sortOrder = 'asc';
    }
    
    this.sortChange.emit({ field, order: this.sortOrder });
  }
  
  onPageChange(page: number): void {
    this.currentPage = page;
    this.pageChange.emit(page);
  }
  
  onRowClick(row: any): void {
    this.rowClick.emit(row);
  }
}
```

---

## 🗂️ NgRx Store Example

### auth.actions.ts

```typescript
import { createAction, props } from '@ngrx/store';

export const login = createAction(
  '[Auth] Login',
  props<{ phone: string; password: string }>()
);

export const loginSuccess = createAction(
  '[Auth] Login Success',
  props<{ user: any; token: string }>()
);

export const loginFailure = createAction(
  '[Auth] Login Failure',
  props<{ error: string }>()
);

export const logout = createAction('[Auth] Logout');

export const loadUser = createAction('[Auth] Load User');

export const loadUserSuccess = createAction(
  '[Auth] Load User Success',
  props<{ user: any }>()
);
```

### auth.reducer.ts

```typescript
import { createReducer, on } from '@ngrx/store';
import * as AuthActions from './auth.actions';

export interface AuthState {
  user: any | null;
  token: string | null;
  loading: boolean;
  error: string | null;
}

export const initialState: AuthState = {
  user: null,
  token: null,
  loading: false,
  error: null,
};

export const authReducer = createReducer(
  initialState,
  on(AuthActions.login, state => ({
    ...state,
    loading: true,
    error: null
  })),
  on(AuthActions.loginSuccess, (state, { user, token }) => ({
    ...state,
    user,
    token,
    loading: false,
    error: null
  })),
  on(AuthActions.loginFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),
  on(AuthActions.logout, () => initialState)
);
```

### auth.selectors.ts

```typescript
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { AuthState } from './auth.reducer';

export const selectAuthState = createFeatureSelector<AuthState>('auth');

export const selectUser = createSelector(
  selectAuthState,
  state => state.user
);

export const selectToken = createSelector(
  selectAuthState,
  state => state.token
);

export const selectIsAuthenticated = createSelector(
  selectAuthState,
  state => !!state.token
);

export const selectAuthLoading = createSelector(
  selectAuthState,
  state => state.loading
);

export const selectAuthError = createSelector(
  selectAuthState,
  state => state.error
);
```

---

## 🧪 Testing

### overview.component.spec.ts

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { OverviewComponent } from './overview.component';
import { DashboardService } from '../../services/dashboard.service';
import { of } from 'rxjs';

describe('OverviewComponent', () => {
  let component: OverviewComponent;
  let fixture: ComponentFixture<OverviewComponent>;
  let dashboardService: jasmine.SpyObj<DashboardService>;
  
  beforeEach(async () => {
    const dashboardServiceSpy = jasmine.createSpyObj('DashboardService', [
      'getDashboardStats'
    ]);
    
    await TestBed.configureTestingModule({
      imports: [OverviewComponent],
      providers: [
        { provide: DashboardService, useValue: dashboardServiceSpy }
      ]
    }).compileComponents();
    
    dashboardService = TestBed.inject(DashboardService) as jasmine.SpyObj<DashboardService>;
  });
  
  it('should create', () => {
    fixture = TestBed.createComponent(OverviewComponent);
    component = fixture.componentInstance;
    expect(component).toBeTruthy();
  });
  
  it('should load dashboard data on init', () => {
    dashboardService.getDashboardStats.and.returnValue(of({
      totalRevenue: 1000000,
      activeBusinesses: 50,
      // ... more data
    }));
    
    fixture = TestBed.createComponent(OverviewComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
    
    expect(dashboardService.getDashboardStats).toHaveBeenCalled();
  });
});
```

---

## 🚀 Build & Deployment

### angular.json (excerpt)

```json
{
  "projects": {
    "hivork-admin": {
      "architect": {
        "build": {
          "configurations": {
            "production": {
              "budgets": [
                {
                  "type": "initial",
                  "maximumWarning": "2mb",
                  "maximumError": "5mb"
                }
              ],
              "outputHashing": "all",
              "optimization": true,
              "sourceMap": false,
              "namedChunks": false,
              "extractLicenses": true,
              "vendorChunk": false,
              "buildOptimizer": true
            }
          }
        }
      }
    }
  }
}
```

---

📅 **تاریخ**: 15 نوامبر 2025  
🔄 **نسخه**: 1.0  
🖥️ **پلتفرم**: Angular 17+
