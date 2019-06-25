package database

import (
	"context"

	"github.com/Laica-Lunasys/hello-golang/models"
	"github.com/volatiletech/sqlboiler/boil"
)

func (a *App) InsertUser(u *models.User) error {
	if err := u.Insert(context.Background(), a.db, boil.Infer()); err != nil {
		return err
	}

	return nil
}

func (a *App) GetUser(id int) (*models.User, error) {
	return models.FindUser(context.Background(), a.db, int64(id))
}

func (a *App) ListUsers() ([]*models.User, error) {
	counts, err := models.Users().Count(context.Background(), a.db)
	if err != nil {
		return nil, err
	} else if counts == 0 {
		return make([]*models.User, 0), nil
	}

	return models.Users().All(context.Background(), a.db)
}

func (a *App) UpdateUser(id int, name string, email string) (*models.User, error) {
	user, err := models.FindUser(context.Background(), a.db, int64(id))
	if err != nil {
		return nil, err
	}

	user.Name = name
	user.Email = email
	_, err = user.Update(context.Background(), a.db, boil.Infer())
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (a *App) DeleteUser(id int) error {
	user, err := models.FindUser(context.Background(), a.db, int64(id))
	if err != nil {
		return err
	}

	_, err = user.Delete(context.Background(), a.db)
	if err != nil {
		return err
	}
	return nil
}
