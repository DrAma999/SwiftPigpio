#ifndef pigpio_shim_h
#define pigpio_shim_h

#include "pigpio.h"
#include "pigpiod_if2.h"

// --------------------
// GPIO Modes
// --------------------
static const uint32_t MODE_INPUT   = PI_INPUT;
static const uint32_t MODE_OUTPUT  = PI_OUTPUT;
static const uint32_t MODE_ALT0    = PI_ALT0;
static const uint32_t MODE_ALT1    = PI_ALT1;
static const uint32_t MODE_ALT2    = PI_ALT2;
static const uint32_t MODE_ALT3    = PI_ALT3;
static const uint32_t MODE_ALT4    = PI_ALT4;
static const uint32_t MODE_ALT5    = PI_ALT5;

// --------------------
// Pull-up / Pull-down
// --------------------
static const uint32_t PUD_OFF  = PI_PUD_OFF;
static const uint32_t PUD_DOWN = PI_PUD_DOWN;
static const uint32_t PUD_UP   = PI_PUD_UP;

// --------------------
// GPIO Levels
// --------------------
static const uint32_t LEVEL_LOW  = PI_LOW;
static const uint32_t LEVEL_HIGH = PI_HIGH;

// --------------------
// PWM / Servo
// --------------------
static const uint32_t PWM_DUTYCYCLE_RANGE_DEFAULT = PI_DEFAULT_DUTYCYCLE_RANGE;

// --------------------
// SPI Modes
// --------------------
// static const uint32_t SPI_MODE_0 = PI_SPI_MODE_0;
// static const uint32_t SPI_MODE_1 = PI_SPI_MODE_1;
// static const uint32_t SPI_MODE_2 = PI_SPI_MODE_2;
// static const uint32_t SPI_MODE_3 = PI_SPI_MODE_3;

// --------------------
// Error Codes
// --------------------
static const int32_t ERROR_INIT_FAILED   = PI_INIT_FAILED;
static const int32_t ERROR_BAD_USER_GPIO = PI_BAD_USER_GPIO;
static const int32_t ERROR_BAD_GPIO      = PI_BAD_GPIO;
static const int32_t ERROR_BAD_MODE      = PI_BAD_MODE;
static const int32_t ERROR_BAD_LEVEL     = PI_BAD_LEVEL;
static const int32_t ERROR_BAD_PUD       = PI_BAD_PUD;
static const int32_t ERROR_BAD_DUTYCYCLE = PI_BAD_DUTYCYCLE;
static const int32_t ERROR_BAD_DUTYRANGE = PI_BAD_DUTYRANGE;
// (pigpio has many more error codes, add as needed)


// =====================
// GPIO Shims
// =====================

// GPIO Error
static const int32_t BAD_GPIO = PI_BAD_GPIO;
static const int32_t NOT_HPWM_GPIO = PI_NOT_HPWM_GPIO;
static const int32_t BAD_HPWM_DUTY = PI_BAD_HPWM_DUTY;
static const int32_t BAD_HPWM_FREQ = PI_BAD_HPWM_FREQ;
static const int32_t HPWM_ILLEGAL = PI_HPWM_ILLEGAL;

// --------------------
// Daemon mode (pigpiod socket)
// --------------------
static inline int shim_pigpioStart(const char *addr, const char *port) {
    return pigpio_start(addr, port);
}

static inline void shim_pigpioStop(int pi) { pigpio_stop(pi); }

static inline int shim_gpioSetPullUpDownDaemon(int pi, unsigned pin, uint32_t pud) {
    return set_pull_up_down(pi, pin, pud);
}

static inline int shim_gpioWriteDaemon(int pi, unsigned gpio, unsigned level) {
    return gpio_write(pi, gpio, level);
}

static inline int shim_gpioSetModeDaemon(int pi, unsigned gpio, unsigned mode) {
    return set_mode(pi, gpio, mode);
}

static inline int shim_gpioReadDaemon(int pi, unsigned gpio) {
    return gpio_read(pi, gpio);
}

static inline int shim_gpioHardwarePWMDaemon(int pi, unsigned gpio, unsigned frequency, unsigned duty) {
    return hardware_PWM(pi, gpio, frequency, duty);
}

static inline int shim_gpioPWMDaemon(int pi, unsigned gpio, uint32_t duty) {
    return set_PWM_dutycycle(pi, gpio, duty);
}

static inline int shim_getPWMDutycycleDaemon(int pi, unsigned gpio) {
    return get_PWM_dutycycle(pi, gpio);
}

static inline int shim_getPWMFrequencyDaemon(int pi, unsigned gpio) {
    return get_PWM_frequency(pi, gpio);
}

static inline int shim_setPWMFrequencyDaemon(int pi, unsigned gpio, unsigned frequency) {
    return set_PWM_frequency(pi, gpio, frequency);
}

static inline int shim_setPWMRangeDaemon(int pi, unsigned gpio, unsigned range) {
    return set_PWM_range(pi, gpio, range);
}

static inline int shim_getPWMRangeDaemon(int pi, unsigned gpio) {
    return get_PWM_range(pi, gpio);
}

static inline int shim_getPWMRealRangeDaemon(int pi, unsigned gpio) {
    return get_PWM_real_range(pi, gpio);
}

static inline int shim_setServoPulsewidthDaemon(int pi,
                                          unsigned gpio,
                                          unsigned pulsewidth)
{
    return set_servo_pulsewidth(pi,
                                gpio,
                                pulsewidth);
}

static inline int shim_getServoPulsewidthDaemon(int pi,
                                          unsigned gpio)
{
    return get_servo_pulsewidth(pi,
                                gpio);
}



// --------------------
// Direct mode 
// --------------------

static inline int shim_gpioSetPullUpDown(unsigned pin, uint32_t pud) {
    return gpioSetPullUpDown(pin, pud);
}

static inline int shim_gpioWrite(unsigned pin, uint32_t level) {
    return gpioWrite(pin, level);
}

static inline int shim_gpioSetMode(unsigned pin, uint32_t mode) {
    return gpioSetMode(pin, mode);
}

static inline int shim_gpioRead(unsigned pin) {
    return gpioRead(pin);
}

static inline int shim_gpioPWM(unsigned pin, uint32_t duty) {
    return gpioPWM(pin, duty);
}

static inline int shim_getPWMDutycycle(unsigned pin) {
    return gpioGetPWMdutycycle(pin);
}

static inline int shim_gpioSetPWMfrequency(unsigned user_gpio, unsigned frequency) {
    return gpioSetPWMfrequency(user_gpio, frequency);
}

static inline int shim_getPWMFrequency(unsigned pin) {
    return gpioGetPWMfrequency(pin);
}

static inline int shim_setPWMRange(unsigned pin, unsigned range) {
    return gpioSetPWMrange(pin, range);
}

static inline int shim_getPWMRange(unsigned pin) {
    return gpioGetPWMrange(pin);
}

static inline int shim_getPWMRealRange(unsigned pin) {
    return gpioGetPWMrealRange(pin);
}


static inline int shim_gpioHardwarePWM(unsigned pin, uint32_t freq, uint32_t duty) {
    return gpioHardwarePWM(pin, freq, duty);
}

static inline int shim_gpioServo(unsigned gpio,
                                 unsigned pulsewidth)
{
    return gpioServo(gpio,
                     pulsewidth);
}

static inline int shim_gpioGetServoPulsewidth(unsigned gpio)
{
    return gpioGetServoPulsewidth(gpio);
}


// =======================
// SPI Shims
// =======================

// SPI Error
static const int32_t BAD_SPI_CHANNEL = PI_BAD_SPI_CHANNEL;
static const int32_t BAD_SPI_SPEED = PI_BAD_SPI_SPEED;
static const int32_t BAD_SPI_FLAGS = PI_BAD_FLAGS;
static const int32_t NO_AUX_SPI = PI_NO_AUX_SPI;
static const int32_t SPI_OPEN_FAILED = PI_SPI_OPEN_FAILED;
static const int32_t BAD_SPI_HANDLE = PI_BAD_HANDLE;
static const int32_t BAD_SPI_COUNT = PI_BAD_SPI_COUNT;
static const int32_t SPI_XFER_FAILED = PI_SPI_XFER_FAILED;

// --------------------
// Daemon mode (pigpiod socket)
// --------------------

// Wraps spi_open
static inline int shim_spiOpenDaemon(int32_t pi,
                               uint32_t channel,
                               uint32_t baud,
                               uint32_t flags)
{
    return spi_open((int)pi,
                    (unsigned)channel,
                    (unsigned)baud,
                    (unsigned)flags);
}

// Wraps spi_close
static inline int shim_spiCloseDaemon(int32_t pi,
                                uint32_t handle)
{
    return spi_close((int)pi, (unsigned)handle);
}

// Wraps spi_read
static inline int shim_spiReadDaemon(int32_t pi,
                               uint32_t handle,
                               char *buf,
                               uint32_t count)
{
    return spi_read((int)pi,
                    (unsigned)handle,
                    buf,
                    (unsigned)count);
}

// Wraps spi_write
static inline int shim_spiWriteDaemon(int32_t pi,
                                uint32_t handle,
                                char *buf,
                                uint32_t count)
{
    return spi_write((int)pi,
                     (unsigned)handle,
                     buf,
                     (unsigned)count);
}

// Wraps spi_xfer (full-duplex)
static inline int shim_spiXferDaemon(int32_t pi,
                               uint32_t handle,
                               char *txBuf,
                               char *rxBuf,
                               uint32_t count)
{
    return spi_xfer((int)pi,
                    (unsigned)handle,
                    txBuf,
                    rxBuf,
                    (unsigned)count);
}

// --------------------
// Direct mode 
// --------------------

// Wraps spiOpen
static inline int shim_spiOpen(uint32_t channel,
                               uint32_t baud,
                               uint32_t flags)
{
    return spiOpen((unsigned)channel, (unsigned)baud, (unsigned)flags);
}

// Wraps spiClose
static inline int shim_spiClose(uint32_t handle)
{
    return spiClose((unsigned)handle);
}

// Wraps spiRead
static inline int shim_spiRead(uint32_t handle,
                               char *buf,
                               uint32_t count)
{
    return spiRead((unsigned)handle, buf, (unsigned)count);
}

// Wraps spiWrite
static inline int shim_spiWrite(uint32_t handle,
                                char *buf,
                                uint32_t count)
{
    return spiWrite((unsigned)handle, buf, (unsigned)count);
}

// Wraps spiXfer (full-duplex)
static inline int shim_spiXfer(uint32_t handle,
                               char *txBuf,
                               char *rxBuf,
                               uint32_t count)
{
    return spiXfer((unsigned)handle, txBuf, rxBuf, (unsigned)count);
}

// =======================
// I²C Shims
// =======================

// Error
static const int32_t BAD_I2C_BUS = PI_BAD_I2C_BUS;
static const int32_t BAD_I2C_ADDR = PI_BAD_I2C_ADDR;
static const int32_t BAD_I2C_FLAGS = PI_BAD_FLAGS;
static const int32_t NO_I2C_HANDLE = PI_NO_HANDLE;
static const int32_t I2C_OPEN_FAILED = PI_I2C_OPEN_FAILED;

// --------------------
// Daemon mode (pigpiod socket)
// --------------------
// Wraps i2c_open
static inline int shim_i2cOpenDaemon(int32_t pi,
                               uint32_t bus,
                               uint32_t address,
                               uint32_t flags)
{
    return i2c_open((int)pi,
                    (unsigned)bus,
                    (unsigned)address,
                    (unsigned)flags);
}

// Wraps i2c_close
static inline int shim_i2cCloseDaemon(int32_t pi,
                                uint32_t handle)
{
    return i2c_close((int)pi, (unsigned)handle);
}

// Wraps i2c_read_device
static inline int shim_i2cReadDeviceDaemon(int32_t pi,
                                     uint32_t handle,
                                     char *buf,
                                     uint32_t count)
{
    return i2c_read_device((int)pi,
                           (unsigned)handle,
                           buf,
                           (unsigned)count);
}

// Wraps i2c_write_device
static inline int shim_i2cWriteDeviceDaemon(int32_t pi,
                                      uint32_t handle,
                                      char *buf,
                                      uint32_t count)
{
    return i2c_write_device((int)pi,
                            (unsigned)handle,
                            buf,
                            (unsigned)count);
}

// Wraps i2c_read_byte_data
static inline int shim_i2cReadByteDataDaemon(int32_t pi,
                                       uint32_t handle,
                                       uint32_t reg)
{
    return i2c_read_byte_data((int)pi,
                              (unsigned)handle,
                              (unsigned)reg);
}

// Wraps i2c_write_byte_data
static inline int shim_i2cWriteByteDataDaemon(int32_t pi,
                                        uint32_t handle,
                                        uint32_t reg,
                                        uint32_t byteVal)
{
    return i2c_write_byte_data((int)pi,
                               (unsigned)handle,
                               (unsigned)reg,
                               (unsigned)byteVal);
}

// Wraps i2c_read_byte
static inline int shim_i2cReadByteDaemon(int32_t pi, uint32_t handle)
{
    return i2c_read_byte((int)pi, (unsigned)handle);
}

// Wraps i2c_write_byte
static inline int shim_i2cWriteByteDaemon(int32_t pi, uint32_t handle, uint32_t byteVal)
{
    return i2c_write_byte((int)pi, (unsigned)handle, (unsigned)byteVal);
}

// Wraps i2c_read_word_data
static inline int shim_i2cReadWordDataDaemon(int32_t pi, uint32_t handle, uint32_t reg)
{
    return i2c_read_word_data((int)pi, (unsigned)handle, (unsigned)reg);
}

// Wraps i2c_write_word_data
static inline int shim_i2cWriteWordDataDaemon(int32_t pi, uint32_t handle, uint32_t reg, uint32_t wordVal)
{
    return i2c_write_word_data((int)pi, (unsigned)handle, (unsigned)reg, (unsigned)wordVal);
}

// Wraps i2c_read_block_data
static inline int shim_i2cReadBlockDataDaemon(int32_t pi, uint32_t handle, uint32_t reg, char *buf)
{
    return i2c_read_block_data((int)pi, (unsigned)handle, (unsigned)reg, buf);
}

// Wraps i2c_write_block_data
static inline int shim_i2cWriteBlockDataDaemon(int32_t pi, uint32_t handle, uint32_t reg, char *buf, uint32_t count)
{
    return i2c_write_block_data((int)pi, (unsigned)handle, (unsigned)reg, buf, (unsigned)count);
}

// Wraps i2c_read_i2c_block_data
static inline int shim_i2cReadI2CBlockDataDaemon(int32_t pi, uint32_t handle, uint32_t reg, char *buf, uint32_t count)
{
    return i2c_read_i2c_block_data((int)pi, (unsigned)handle, (unsigned)reg, buf, (unsigned)count);
}

// Wraps i2c_write_i2c_block_data
static inline int shim_i2cWriteI2CBlockDataDaemon(int32_t pi, uint32_t handle, uint32_t reg, char *buf, uint32_t count)
{
    return i2c_write_i2c_block_data((int)pi, (unsigned)handle, (unsigned)reg, buf, (unsigned)count);
}

// --------------------
// Direct mode 
// --------------------

// Wraps i2cOpen
static inline int shim_i2cOpen(uint32_t bus,
                               uint32_t address,
                               uint32_t flags)
{
    return i2cOpen((unsigned)bus, (unsigned)address, (unsigned)flags);
}

// Wraps i2cClose
static inline int shim_i2cClose(uint32_t handle)
{
    return i2cClose((unsigned)handle);
}

// Wraps i2cReadDevice
static inline int shim_i2cReadDevice(uint32_t handle,
                                     char *buf,
                                     uint32_t count)
{
    return i2cReadDevice((unsigned)handle, buf, (unsigned)count);
}

// Wraps i2cWriteDevice
static inline int shim_i2cWriteDevice(uint32_t handle,
                                      char *buf,
                                      uint32_t count)
{
    return i2cWriteDevice((unsigned)handle, buf, (unsigned)count);
}

// Wraps i2cReadByteData
static inline int shim_i2cReadByteData(uint32_t handle, uint32_t reg)
{
    return i2cReadByteData((unsigned)handle, (unsigned)reg);
}

// Wraps i2cWriteByteData
static inline int shim_i2cWriteByteData(uint32_t handle,
                                        uint32_t reg,
                                        uint32_t byteVal)
{
    return i2cWriteByteData((unsigned)handle, (unsigned)reg, (unsigned)byteVal);
}

// Wraps i2cReadByte
static inline int shim_i2cReadByte(uint32_t handle)
{
    return i2cReadByte((unsigned)handle);
}

// Wraps i2cWriteByte
static inline int shim_i2cWriteByte(uint32_t handle, uint32_t byteVal)
{
    return i2cWriteByte((unsigned)handle, (unsigned)byteVal);
}

// Wraps i2cReadWordData
static inline int shim_i2cReadWordData(uint32_t handle, uint32_t reg)
{
    return i2cReadWordData((unsigned)handle, (unsigned)reg);
}

// Wraps i2cWriteWordData
static inline int shim_i2cWriteWordData(uint32_t handle, uint32_t reg, uint32_t wordVal)
{
    return i2cWriteWordData((unsigned)handle, (unsigned)reg, (unsigned)wordVal);
}

// Wraps i2cReadBlockData
static inline int shim_i2cReadBlockData(uint32_t handle, uint32_t reg, char *buf)
{
    return i2cReadBlockData((unsigned)handle, (unsigned)reg, buf);
}

// Wraps i2cWriteBlockData
static inline int shim_i2cWriteBlockData(uint32_t handle, uint32_t reg, char *buf, uint32_t count)
{
    return i2cWriteBlockData((unsigned)handle, (unsigned)reg, buf, (unsigned)count);
}

// Wraps i2cReadI2CBlockData
static inline int shim_i2cReadI2CBlockData(uint32_t handle, uint32_t reg, char *buf, uint32_t count)
{
    return i2cReadI2CBlockData((unsigned)handle, (unsigned)reg, buf, (unsigned)count);
}

// Wraps i2cWriteI2CBlockData
static inline int shim_i2cWriteI2CBlockData(uint32_t handle, uint32_t reg, char *buf, uint32_t count)
{
    return i2cWriteI2CBlockData((unsigned)handle, (unsigned)reg, buf, (unsigned)count);
}



#endif /* pigpio_shim_h */
