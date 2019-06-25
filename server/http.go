package server

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/Laica-Lunasys/hello-golang/models"

	"github.com/Laica-Lunasys/hello-golang/database"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

type httpServer struct {
	server Server
}

type httpError struct {
	Message error `json:"message"`
}

func NewHTTPServer(s Server) *echo.Echo {
	e := echo.New()
	e.Use(middleware.Recover())

	server := &httpServer{s}

	e.GET("/", server.Pong)

	e.GET("/users", server.ListUsers)
	e.GET("/users/:id", server.GetUser)

	e.POST("/users", server.AddUser)
	e.PUT("/users/:id", server.UpdateUser)
	e.DELETE("/users/:id", server.DeleteUser)

	return e
}

func (s *httpServer) Pong(c echo.Context) (err error) {
	r := struct {
		Message string `json:"message"`
	}{"Hello World!!"}
	return c.JSON(http.StatusOK, r)
}

func (s *httpServer) ListUsers(c echo.Context) (err error) {
	r, err := database.GetConn().ListUsers()
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, r)
}

func (s *httpServer) GetUser(c echo.Context) (err error) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, errors.New("invalid id").Error())
	}

	r, err := database.GetConn().GetUser(id)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, r)
}

func (s *httpServer) AddUser(c echo.Context) (err error) {
	u := new(models.User)
	if err = c.Bind(u); err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	if err = database.GetConn().InsertUser(u); err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, u)
}

func (s *httpServer) UpdateUser(c echo.Context) (err error) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, errors.New("invalid id").Error())
	}

	u := new(models.User)
	if err = c.Bind(u); err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	r, err := database.GetConn().UpdateUser(id, u.Name, u.Email)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, r)
}

func (s *httpServer) DeleteUser(c echo.Context) (err error) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, errors.New("invalid id").Error())
	}

	err = database.GetConn().DeleteUser(id)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.NoContent(http.StatusNoContent)
}
